import 'package:flutter/widgets.dart';
import 'package:nard_core/nard_core.dart';

import '../theme/board_theme.dart';
import 'board_layout.dart';
import 'board_painter.dart';
import 'board_scene.dart';

/// Static, non-interactive board (onboarding cards, previews).
class BoardPreview extends StatelessWidget {
  const BoardPreview({
    super.key,
    required this.scene,
    this.height = BoardGeometry.heightLandscape,
  });

  final BoardScene scene;
  final double height;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: BoardGeometry.width / height,
    child: CustomPaint(painter: _PreviewPainter(scene, height)),
  );
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.scene, this.height);

  final BoardScene scene;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = BoardLayout(
      rules: scene.rules,
      viewer: scene.viewer,
      height: height,
    );
    canvas.save();
    canvas.scale(size.width / BoardGeometry.width);
    BoardPainter.paintBoard(canvas, layout, scene);
    for (final side in Side.values) {
      for (var slot = 1; slot <= BoardState.bar; slot++) {
        final n = scene.board.count(side, slot);
        for (var k = 0; k < n; k++) {
          final c = layout.slotCenter(side, slot, k, n);
          final r =
              slot == BoardState.bar
                  ? BoardGeometry.barChecker / 2
                  : BoardGeometry.checker / 2;
          BoardPainter.paintChecker(
            canvas,
            c,
            r,
            side,
            colorBlind: scene.colorBlind,
            material: scene.material(side),
          );
          if (k == n - 1 && slot != BoardState.bar && n > layout.maxFit) {
            BoardPainter.paintCount(canvas, c, n, side);
          }
        }
      }
    }
    if (scene.cubeVisible) {
      BoardPainter.paintCube(canvas, layout.cubeCenter(scene.cubeOwner), '64');
    }
    for (var j = 0; j < scene.dice.length; j++) {
      BoardPainter.paintDie(
        canvas,
        layout.diceCenter(j, scene.dice.length, viewerSide: true),
        scene.dice[j],
        dice: scene.diceLook,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.scene != scene;
}
