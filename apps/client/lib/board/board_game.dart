import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:nard_core/nard_core.dart';

import '../theme/board_theme.dart';
import '../theme/nard_tokens.dart';
import 'board_layout.dart';
import 'board_painter.dart';
import 'board_scene.dart';

/// The Flame board: renders a [BoardScene] in the 640 × H logical space,
/// animates checkers between scenes and reports taps and drags in the
/// mover's slot numbering.
class NardBoardGame extends FlameGame {
  NardBoardGame({
    required this.boardHeight,
    this.onTapSlot,
    this.onDrop,
    this.canDrag,
    this.reduceMotion = false,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: BoardGeometry.width,
           height: boardHeight,
         ),
       );

  final double boardHeight;

  /// A tap on a slot of the mover (null: outside any slot).
  final void Function(int? slot)? onTapSlot;

  /// A checker dragged from [from] and dropped on [to] (null: nowhere).
  final void Function(int from, int? to)? onDrop;

  /// Whether the mover's checker on [slot] may be picked up.
  final bool Function(int slot)? canDrag;

  bool reduceMotion;

  /// Length of a dice throw (set from the animation speed).
  Duration rollTime = const Duration(milliseconds: 800);

  BoardScene? _scene;
  BoardLayout? _layout;
  final _sprites = <Side, Map<int, List<_CheckerSprite>>>{};
  final _queue = <BoardState>[];
  double _busy = 0;
  _CheckerSprite? _dragging;
  int? _dragFrom;

  BoardScene? get scene => _scene;
  BoardLayout? get layout => _layout;

  @override
  Color backgroundColor() => const Color(0x00000000);

  Duration get _checkerTime =>
      reduceMotion ? const Duration(milliseconds: 120) : NardMotion.checker;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    await world.addAll([
      _BoardLayer(),
      _TopLayer()..priority = 50,
      _InputLayer()..priority = 100,
    ]);
    final pending = _scene;
    if (pending != null) _build(pending);
  }

  /// Shows [scene]. [steps] are intermediate positions (one per move) that
  /// are animated in order before the scene's own board.
  void show(BoardScene scene, {List<BoardState> steps = const []}) {
    final previous = _scene;
    _scene = scene;
    _layout = BoardLayout(
      rules: scene.rules,
      viewer: scene.viewer,
      height: boardHeight,
    );
    if (!isLoaded) return;
    if (previous == null ||
        previous.rules.variant != scene.rules.variant ||
        _sprites.isEmpty) {
      _build(scene);
      return;
    }
    if (_dragging != null) _cancelDrag();
    _queue
      ..addAll(steps)
      ..add(scene.board);
    if (_busy <= 0) _advance();
  }

  void _build(BoardScene scene) {
    for (final stacks in _sprites.values) {
      for (final list in stacks.values) {
        for (final s in list) {
          s.removeFromParent();
        }
      }
    }
    _sprites.clear();
    _queue.clear();
    _busy = 0;
    final l = _layout!;
    for (final side in Side.values) {
      final stacks = <int, List<_CheckerSprite>>{};
      for (var slot = 0; slot <= BoardState.bar; slot++) {
        final n = scene.board.count(side, slot);
        final list = <_CheckerSprite>[];
        for (var k = 0; k < n; k++) {
          final sprite =
              _CheckerSprite(side)
                ..slot = slot
                ..position = _vec(l.slotCenter(side, slot, k, n));
          list.add(sprite);
          world.add(sprite);
        }
        stacks[slot] = list;
      }
      _sprites[side] = stacks;
    }
  }

  void _advance() {
    if (_queue.isEmpty) return;
    final target = _queue.removeAt(0);
    _busy = _sync(target, animate: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_busy > 0) {
      _busy -= dt;
      if (_busy <= 0) _advance();
    }
  }

  /// Moves sprites so they match [target]; returns the animation length.
  double _sync(BoardState target, {required bool animate}) {
    final l = _layout!;
    final moved = <_CheckerSprite>{};
    for (final side in Side.values) {
      final stacks = _sprites[side]!;
      final leaving = <_CheckerSprite>[];
      for (var slot = BoardState.bar; slot >= 0; slot--) {
        final list = stacks[slot]!;
        while (list.length > target.count(side, slot)) {
          leaving.add(list.removeLast());
        }
      }
      for (var slot = BoardState.bar; slot >= 0; slot--) {
        final list = stacks[slot]!;
        while (list.length < target.count(side, slot) && leaving.isNotEmpty) {
          final sprite = leaving.removeAt(0)..slot = slot;
          list.add(sprite);
          moved.add(sprite);
        }
      }
    }
    final slide = _checkerTime.inMilliseconds / 1000;
    for (final side in Side.values) {
      for (final entry in _sprites[side]!.entries) {
        final list = entry.value;
        for (var k = 0; k < list.length; k++) {
          final sprite = list[k];
          final to = _vec(l.slotCenter(side, entry.key, k, list.length));
          if (!animate) {
            sprite.position = to;
          } else if (moved.contains(sprite)) {
            sprite.glide(to, slide, arc: !reduceMotion);
          } else if (sprite.position.distanceTo(to) > .5) {
            sprite.glide(to, .12, arc: false);
          }
        }
      }
    }
    return moved.isEmpty || !animate ? 0 : slide + .02;
  }

  /// Lays every checker out again (after a refused drop or a flip).
  void relayout() {
    final scene = _scene;
    if (scene == null || !isLoaded) return;
    _sync(_queue.isEmpty ? scene.board : _queue.last, animate: true);
  }

  _CheckerSprite? _topSprite(Side side, int slot) {
    final list = _sprites[side]?[slot];
    return list == null || list.isEmpty ? null : list.last;
  }

  void _startDrag(Offset pos) {
    final scene = _scene;
    final mover = scene?.mover;
    if (scene == null || mover == null || _busy > 0) return;
    final slot = _layout!.slotAt(mover, pos);
    if (slot == null || slot == BoardState.off) return;
    if (!(canDrag?.call(slot) ?? false)) return;
    final sprite = _topSprite(mover, slot);
    if (sprite == null) return;
    _dragging = sprite..dragged = true;
    _dragFrom = slot;
    sprite.priority = 40;
  }

  void _updateDrag(Offset pos) {
    _dragging?.position = _vec(pos);
  }

  void _endDrag(Offset pos) {
    final sprite = _dragging;
    final from = _dragFrom;
    if (sprite == null || from == null) return;
    _dragging = null;
    _dragFrom = null;
    sprite
      ..dragged = false
      ..priority = 10;
    final to = _layout!.slotAt(_scene!.mover!, pos);
    if (to == null || to == from) {
      relayout();
      onTapSlot?.call(from);
      return;
    }
    // The controller shows a new scene if the move is accepted; otherwise
    // the checker returns to its point.
    onDrop?.call(from, to);
    if (_queue.isEmpty && _busy <= 0) relayout();
  }

  void _cancelDrag() {
    _dragging
      ?..dragged = false
      ..priority = 10;
    _dragging = null;
    _dragFrom = null;
  }

  static Vector2 _vec(Offset o) => Vector2(o.dx, o.dy);
}

class _BoardLayer extends Component with HasGameReference<NardBoardGame> {
  @override
  void render(Canvas canvas) {
    final scene = game.scene;
    final layout = game.layout;
    if (scene == null || layout == null) return;
    BoardPainter.paintBoard(canvas, layout, scene, slabs: false);
  }
}

/// One checker; renders as a borne-off slab while in the off slot.
class _CheckerSprite extends PositionComponent
    with HasGameReference<NardBoardGame> {
  _CheckerSprite(this.side) : super(priority: 10);

  final Side side;
  int slot = 0;
  bool dragged = false;

  Vector2? _from;
  Vector2? _to;
  double _t = 0;
  double _dur = 0;
  bool _arc = false;

  void glide(Vector2 to, double seconds, {required bool arc}) {
    _from = position.clone();
    _to = to;
    _t = 0;
    _dur = seconds;
    _arc = arc;
    priority = 20;
  }

  @override
  void update(double dt) {
    final to = _to;
    if (to == null) return;
    _t += dt;
    final p = (_t / _dur).clamp(0.0, 1.0);
    final e = NardMotion.checkerCurve.transform(p);
    final from = _from!;
    position = from + (to - from) * e;
    if (_arc) {
      final lift = min(60.0, from.distanceTo(to) * .25);
      position.y -= sin(pi * e) * lift;
    }
    if (p >= 1) {
      position = to;
      _to = null;
      priority = 10;
    }
  }

  bool get _moving => _to != null || dragged;

  @override
  void render(Canvas canvas) {
    final scene = game.scene;
    final layout = game.layout;
    if (scene == null || layout == null) return;
    final c = Offset(position.x, position.y);
    // Rendering in world space: undo the component transform.
    canvas.save();
    canvas.translate(-position.x, -position.y);
    if (slot == BoardState.off && !_moving) {
      BoardPainter.paintSlab(canvas, c - const Offset(20, 5), side);
      canvas.restore();
      return;
    }
    final onBar = slot == BoardState.bar && !_moving;
    final r = (onBar ? BoardGeometry.barChecker : BoardGeometry.checker) / 2;
    final list = game._sprites[side]?[slot];
    final isTop = list != null && list.isNotEmpty && identical(list.last, this);
    var center = c;
    final selected =
        isTop && !_moving && scene.mover == side && scene.selected == slot;
    if (selected) {
      // Lift toward the board centre.
      final up = center.dy > layout.midY ? -5.0 : 5.0;
      center = center.translate(0, up);
      canvas.drawCircle(
        center,
        r + 6,
        Paint()
          ..color = const Color(0x8CF0CD6E)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }
    if (onBar && scene.mustEnter && scene.mover == side) {
      canvas.drawCircle(
        center,
        r + 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = BoardOverlay.selectRing,
      );
    }
    BoardPainter.paintChecker(
      canvas,
      center,
      r,
      side,
      colorBlind: scene.colorBlind,
      material: scene.material(side),
    );
    if (selected) {
      canvas.drawCircle(
        center,
        r + 1.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = BoardOverlay.selectRing,
      );
    } else if (isTop &&
        !_moving &&
        scene.lastMover == side &&
        scene.lastMoves.any((m) => m.to == slot)) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0x99F0CD6E),
      );
    }
    if (isTop &&
        !_moving &&
        slot >= 1 &&
        slot <= 24 &&
        list.length > layout.maxFit) {
      BoardPainter.paintCount(canvas, center, list.length, side);
    }
    canvas.restore();
  }
}

/// Dice and cube, above the checkers.
class _TopLayer extends Component with HasGameReference<NardBoardGame> {
  final _random = Random();
  _DiceThrow? _throw;
  bool _wasRolling = false;
  List<int> _thrownFaces = const [];

  @override
  void update(double dt) {
    final scene = game.scene;
    if (scene == null) return;
    final seconds = game.rollTime.inMilliseconds / 1000;
    final newThrow =
        scene.rolling &&
        (!_wasRolling || !_sameFaces(scene.dice, _thrownFaces));
    _wasRolling = scene.rolling;
    if (newThrow && scene.dice.isNotEmpty) {
      _thrownFaces = scene.dice;
      _throw =
          game.reduceMotion || seconds <= 0
              ? null
              : _DiceThrow(
                _random,
                seconds: seconds,
                count: min(2, scene.dice.length),
                fromViewer:
                    scene.diceOwner == null || scene.diceOwner == scene.viewer,
              );
    }
    final t = _throw;
    if (t != null && t.advance(dt)) _throw = null;
  }

  static bool _sameFaces(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void render(Canvas canvas) {
    final scene = game.scene;
    final l = game.layout;
    if (scene == null || l == null) return;
    if (scene.cubeVisible && !scene.cubeOffered) {
      BoardPainter.paintCube(
        canvas,
        l.cubeCenter(scene.cubeOwner),
        scene.cubeOwner == null ? '64' : '${scene.cubeValue}',
      );
    }
    if (scene.cubeOffered) {
      BoardPainter.paintCube(
        canvas,
        Offset(434, l.midY),
        '${scene.cubeValue * 2}',
        size: BoardGeometry.cubeOffer,
        offer: true,
      );
    }
    final n = scene.dice.length;
    if (n == 0) return;
    final mine = scene.diceOwner == null || scene.diceOwner == scene.viewer;
    final size = n > 2 ? 40.0 : BoardGeometry.die;
    final flying = _throw;
    if (flying != null) {
      // Two dice are thrown; doubles show all four once they land. The
      // middle two of four sit where two dice would.
      for (var k = 0; k < flying.count; k++) {
        final j = n > 2 ? k + 1 : k;
        final rest = l.diceCenter(j, n, viewerSide: mine);
        flying.paint(
          canvas,
          k,
          rest: rest,
          boardHeight: l.height,
          finalFace: scene.dice[j],
          finalAngle: _restAngle(j),
          paintDie:
              (c, face, angle, scale) => _paintDie(
                canvas,
                scene,
                c,
                face,
                angle: angle,
                size: size * scale,
              ),
        );
      }
      return;
    }
    for (var j = 0; j < n; j++) {
      _paintDie(
        canvas,
        scene,
        l.diceCenter(j, n, viewerSide: mine),
        scene.dice[j],
        angle: _restAngle(j),
        size: size,
        used: j < scene.diceUsed.length && scene.diceUsed[j],
      );
    }
  }

  static double _restAngle(int j) => (j.isEven ? -3 : 4) * pi / 180;

  void _paintDie(
    Canvas canvas,
    BoardScene scene,
    Offset c,
    int face, {
    required double angle,
    required double size,
    bool used = false,
  }) {
    BoardPainter.paintDie(
      canvas,
      c,
      face,
      size: size,
      angle: angle,
      used: used,
      largePips: scene.largePips,
      dice: scene.diceLook,
    );
  }
}

/// One throw of the dice across the board: each die slides in from the
/// thrower's edge, hops a few times while tumbling, then settles on its
/// resting spot showing the real face.
class _DiceThrow {
  _DiceThrow(
    Random random, {
    required this.seconds,
    required this.count,
    required this.fromViewer,
  }) : _dice = [
         for (var k = 0; k < count; k++)
           (
             dx: 70 + random.nextDouble() * 70 + k * 18,
             curve: (random.nextDouble() - .5) * 50,
             spin:
                 (random.nextBool() ? 1 : -1) *
                 (2.5 + random.nextDouble() * 1.5) *
                 pi,
             faces: [for (var i = 0; i < 12; i++) random.nextInt(6) + 1],
             delay: k * .06,
           ),
       ];

  final double seconds;
  final int count;

  /// Thrown from the bottom edge (the viewer) or from the top.
  final bool fromViewer;

  final List<
    ({double dx, double curve, double spin, List<int> faces, double delay})
  >
  _dice;
  double _elapsed = 0;

  /// Share of the throw after which the dice lie still.
  static const _settle = .78;

  /// Advances the throw; true once it is over.
  bool advance(double dt) {
    _elapsed += dt;
    return _elapsed >= seconds;
  }

  /// Height above the board (0..1): three hops that die away.
  static double _hop(double t) {
    const hops = [(0.0, .34, 1.0), (.34, .58, .42), (.58, _settle, .16)];
    for (final (a, b, amp) in hops) {
      if (t < b) return amp * sin(pi * (t - a) / (b - a)).abs();
    }
    return 0;
  }

  void paint(
    Canvas canvas,
    int k, {
    required Offset rest,
    required double boardHeight,
    required int finalFace,
    required double finalAngle,
    required void Function(Offset c, int face, double angle, double scale)
    paintDie,
  }) {
    final d = _dice[k];
    final raw = ((_elapsed / seconds) - d.delay) / (1 - d.delay);
    final t = raw.clamp(0.0, 1.0);
    final glide = (t / _settle).clamp(0.0, 1.0);
    // Fast at first, slowing down as the die rolls out.
    final e = 1 - pow(1 - glide, 3).toDouble();
    final start =
        fromViewer
            ? Offset(rest.dx + d.dx, boardHeight - 30)
            : Offset(rest.dx - d.dx, 30);
    final along = Offset.lerp(start, rest, e)!;
    final dir = rest - start;
    final normal = Offset(-dir.dy, dir.dx) / dir.distance;
    final ground = along + normal * (d.curve * sin(pi * e));
    final h = _hop(t);
    final spinLeft = 1 - pow(1 - glide, 2.4).toDouble();
    final angle = finalAngle + d.spin * (1 - spinLeft);
    // A new face each quarter turn while the die still tumbles.
    final turned = (d.spin * spinLeft).abs() / (pi / 2);
    final face =
        t >= _settle ? finalFace : d.faces[turned.floor() % d.faces.length];
    // Shadow on the board under a lifted die.
    canvas.drawCircle(
      ground + Offset(4 + h * 8, 6 + h * 10),
      BoardGeometry.die * (.42 - h * .08),
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, .28 * h)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + h * 6),
    );
    paintDie(ground - Offset(0, h * 16), face, angle, 1 + h * .22);
  }
}

/// Full-board hit area for taps and drags.
class _InputLayer extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameReference<NardBoardGame> {
  Offset? _lastPos;

  @override
  Future<void> onLoad() async {
    size = Vector2(BoardGeometry.width, game.boardHeight);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  Offset _o(Vector2 v) => Offset(v.x, v.y);

  @override
  void onTapUp(TapUpEvent event) {
    final scene = game.scene;
    final mover = scene?.mover;
    if (mover == null) {
      game.onTapSlot?.call(null);
      return;
    }
    game.onTapSlot?.call(game.layout!.slotAt(mover, _o(event.localPosition)));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    game._startDrag(_o(event.localPosition));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _lastPos = _o(event.localEndPosition);
    game._updateDrag(_lastPos!);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    game._endDrag(_lastPos ?? Offset.zero);
    _lastPos = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    game._cancelDrag();
    game.relayout();
  }
}
