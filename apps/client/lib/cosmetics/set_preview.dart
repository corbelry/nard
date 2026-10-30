import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nard_core/nard_core.dart';

import '../board/board_preview.dart';
import '../board/board_scene.dart';
import 'board_look.dart';

/// A static mid-game Short Nard position with dice 6-3 (3.1 preview).
BoardScene previewScene(BoardLook look) => BoardScene(
  rules: rulesFor(Variant.shortNard),
  viewer: Side.white,
  board: BoardState.fromPoints(
    white: const {6: 4, 8: 3, 13: 4, 24: 2, 4: 2},
    black: const {6: 4, 8: 3, 13: 3, 24: 2, 5: 2, 10: 1},
  ),
  dice: const [6, 3],
  diceOwner: Side.white,
  cubeVisible: true,
  look: look,
);

/// The board drawn in [look]; [tilted] adds the Locker's 3D tilt
/// (perspective 900, rotateX 24°).
class SetPreview extends StatelessWidget {
  const SetPreview({
    super.key,
    required this.look,
    this.width = 330,
    this.tilted = false,
  });

  final BoardLook look;
  final double width;
  final bool tilted;

  @override
  Widget build(BuildContext context) {
    Widget board = SizedBox(
      width: width,
      child: BoardPreview(scene: previewScene(look)),
    );
    if (tilted) {
      board = Transform(
        alignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 1 / 900)
              ..translate(0.0, -6.0)
              ..rotateX(24 * pi / 180),
        child: board,
      );
    }
    return board;
  }
}
