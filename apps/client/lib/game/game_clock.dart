import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';

/// Remaining reserve and delay of [side] at [now], from a server snapshot
/// taken at [receivedAt] (spec §7.3).
({int reserveMs, int delayMs, bool running}) clockAt(
  ClockState clock,
  Side side,
  DateTime receivedAt,
  DateTime now,
) {
  final base = side == Side.white ? clock.whiteMs : clock.blackMs;
  if (clock.running != side) {
    return (reserveMs: base, delayMs: 0, running: false);
  }
  final elapsed = now.difference(receivedAt).inMilliseconds;
  return (
    reserveMs: max(0, base - max(0, elapsed - clock.delayMs)),
    delayMs: max(0, clock.delayMs - elapsed),
    running: true,
  );
}

String formatClock(int ms) {
  final s = (ms / 1000).ceil();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Player clock (game.md §3.1): idle, active, or low below 10 s, with the
/// per-turn delay bar. Ticks locally between server updates.
class GameClock extends StatefulWidget {
  const GameClock({
    super.key,
    required this.clock,
    required this.side,
    required this.receivedAt,
    required this.delayTotalMs,
    this.haptics = false,
    this.compact = false,
  });

  final ClockState clock;
  final Side side;
  final DateTime receivedAt;
  final int delayTotalMs;

  /// Tick every second under 10 s (the local player's clock only).
  final bool haptics;
  final bool compact;

  static const lowMs = 10000;

  @override
  State<GameClock> createState() => _GameClockState();
}

class _GameClockState extends State<GameClock> {
  Timer? _timer;
  int _lastTickSecond = -1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final t = clockAt(
      widget.clock,
      widget.side,
      widget.receivedAt,
      DateTime.now(),
    );
    final low = t.running && t.delayMs == 0 && t.reserveMs < GameClock.lowMs;
    if (low && widget.haptics) {
      final second = t.reserveMs ~/ 1000;
      if (second != _lastTickSecond) {
        _lastTickSecond = second;
        unawaited(HapticFeedback.selectionClick());
      }
    }
    final (bg, fg, track) =
        low
            ? (c.danger, c.onDanger, const Color(0x40FFFFFF))
            : t.running
            ? (c.clockActiveBg, c.clockActiveText, const Color(0x26000000))
            : (c.surface, c.textDim, const Color(0x14FFFFFF));
    final fraction =
        widget.delayTotalMs == 0
            ? 0.0
            : t.running
            ? t.delayMs / widget.delayTotalMs
            : 1.0;
    return Semantics(
      label: formatClock(t.reserveMs),
      child: AnimatedContainer(
        duration: NardMotion.fast,
        constraints: const BoxConstraints(minWidth: 74),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              low
                  ? const [
                    BoxShadow(color: Color(0x4DE0566C), spreadRadius: 3),
                    BoxShadow(color: Color(0x73E0566C), blurRadius: 20),
                  ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatClock(t.reserveMs),
              style: NardType.clock.copyWith(
                color: fg,
                fontSize: widget.compact ? 18 : 20,
                fontFeatures: tabular,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 54,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: track)),
                    FractionallySizedBox(
                      widthFactor: fraction.clamp(0, 1),
                      child: ColoredBox(color: fg),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
