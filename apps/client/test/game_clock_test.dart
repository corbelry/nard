import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/game/game_clock.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

void main() {
  final t0 = DateTime(2026);
  const clock = ClockState(
    whiteMs: 60000,
    blackMs: 30000,
    delayMs: 12000,
    running: Side.white,
    sentAt: 0,
  );

  test('the delay runs first, then the reserve (spec §7.3)', () {
    var w = clockAt(clock, Side.white, t0, t0.add(const Duration(seconds: 5)));
    expect((w.reserveMs, w.delayMs, w.running), (60000, 7000, true));
    w = clockAt(clock, Side.white, t0, t0.add(const Duration(seconds: 20)));
    expect((w.reserveMs, w.delayMs), (52000, 0));
    final b = clockAt(
      clock,
      Side.black,
      t0,
      t0.add(const Duration(seconds: 20)),
    );
    expect((b.reserveMs, b.running), (30000, false));
    expect(
      clockAt(
        clock,
        Side.white,
        t0,
        t0.add(const Duration(hours: 1)),
      ).reserveMs,
      0,
    );
  });

  test('formatting rounds up to whole seconds', () {
    expect(formatClock(0), '0:00');
    expect(formatClock(9001), '0:10');
    expect(formatClock(180000), '3:00');
  });
}
