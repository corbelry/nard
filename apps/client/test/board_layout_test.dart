import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/board/board_layout.dart';
import 'package:nard_client/theme/board_theme.dart';
import 'package:nard_core/nard_core.dart';

void main() {
  const short = BoardLayout(
    rules: ShortNardRules(),
    viewer: Side.white,
    height: BoardGeometry.heightPortrait,
  );

  test('derived sizes match the design (portrait / landscape)', () {
    expect(short.pointHeight, 226);
    expect(short.maxFit, 5);
    const land = BoardLayout(
      rules: ShortNardRules(),
      viewer: Side.white,
      height: BoardGeometry.heightLandscape,
    );
    expect(land.pointHeight, 181);
    expect(land.maxFit, 4);
    expect(BoardLayout.trayX, 574);
  });

  test('opponent checkers are mirrored per variant geometry', () {
    expect(short.viewerPoint(Side.black, 24), 1);
    const long = BoardLayout(
      rules: LongNardRules(),
      viewer: Side.white,
      height: BoardGeometry.heightPortrait,
    );
    // Long Nard: Black's head (own 24) sits on White's point 12.
    expect(long.viewerPoint(Side.black, 24), 12);
    expect(long.ownSlot(Side.black, 12), 24);
  });

  test('hit testing finds points, bar and tray', () {
    for (var p = 1; p <= 24; p++) {
      final c = short.checkerCenter(p, 0, 1);
      expect(short.slotAt(Side.white, c), p, reason: 'white $p');
      expect(short.slotAt(Side.black, c), 25 - p, reason: 'black $p');
    }
    expect(short.slotAt(Side.white, const Offset(290, 300)), BoardState.bar);
    final tray = short.tray(Side.white).center;
    expect(short.slotAt(Side.white, tray), BoardState.off);
    expect(short.slotAt(Side.white, const Offset(5, 5)), isNull);
  });

  test('stacks compress beyond maxFit and stay inside the point', () {
    final top = short.checkerCenter(1, 14, 15);
    final base = short.checkerCenter(1, 0, 15);
    expect(base.dy - top.dy, closeTo(short.pointHeight - 38, 1e-9));
  });

  test('a flipped viewer sees the other side at the bottom', () {
    const flipped = BoardLayout(
      rules: ShortNardRules(),
      viewer: Side.black,
      height: BoardGeometry.heightPortrait,
    );
    expect(flipped.viewerPoint(Side.black, 6), 6);
    expect(flipped.viewerPoint(Side.white, 6), 19);
  });
}
