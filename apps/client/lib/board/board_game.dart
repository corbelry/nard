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
  double _rollClock = 0;
  List<int> _faces = const [];

  @override
  void update(double dt) {
    final scene = game.scene;
    if (scene == null || !scene.rolling) return;
    _rollClock += dt;
    if (_rollClock > .08 || _faces.length != scene.dice.length) {
      _rollClock = 0;
      _faces = [for (final _ in scene.dice) _random.nextInt(6) + 1];
    }
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
    for (var j = 0; j < n; j++) {
      final c = l.diceCenter(j, n, viewerSide: mine);
      final rolling = scene.rolling && !game.reduceMotion;
      final face = rolling && _faces.length == n ? _faces[j] : scene.dice[j];
      final tilt =
          rolling
              ? (_random.nextDouble() - .5) * .8
              : (j.isEven ? -3 : 4) * pi / 180;
      final jitter =
          rolling
              ? Offset(
                (_random.nextDouble() - .5) * 16,
                (_random.nextDouble() - .5) * 16,
              )
              : Offset.zero;
      BoardPainter.paintDie(
        canvas,
        c + jitter,
        face,
        size: n > 2 ? 40 : BoardGeometry.die,
        angle: tilt,
        used: j < scene.diceUsed.length && scene.diceUsed[j],
        largePips: scene.largePips,
        dice: scene.diceLook,
      );
    }
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
