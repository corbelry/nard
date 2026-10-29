import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nard_core/nard_core.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/online_text.dart';
import '../online/rank.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import 'game_clock.dart';
import 'game_controller.dart';

/// Rebuilds every [period] (clock-driven UI between server updates).
class PeriodicBuilder extends StatefulWidget {
  const PeriodicBuilder({
    super.key,
    required this.builder,
    this.period = const Duration(milliseconds: 250),
  });

  final WidgetBuilder builder;
  final Duration period;

  @override
  State<PeriodicBuilder> createState() => _PeriodicBuilderState();
}

class _PeriodicBuilderState extends State<PeriodicBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.period, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// My clock is under 10 s on my turn (online.md §3.2).
bool isLowTime(OnlineExtras online, Side me, DateTime now) {
  final t = clockAt(online.clock, me, online.receivedAt ?? now, now);
  return t.running && t.delayMs == 0 && t.reserveMs < GameClock.lowMs;
}

/// Time left before the absent opponent forfeits, measured on the
/// server's clock to avoid device skew; null when nobody is away.
Duration? reconnectLeft(OnlineExtras online, DateTime now) {
  final deadline = online.reconnectDeadline;
  if (deadline == null || online.opponentConnected) return null;
  final elapsed = now.difference(online.receivedAt ?? now).inMilliseconds;
  return Duration(
    milliseconds: max(0, deadline - online.clock.sentAt - elapsed),
  );
}

/// Banner of the online states (§3.2–§3.4), or null for the normal one.
({String title, String? sub, BannerTone tone})? onlineBanner(
  OnlineExtras online,
  Side me,
  AppLocalizations l,
  DateTime now, {
  bool opponentBot = false,
}) {
  if (!online.connected) {
    return (title: l.bannerDisconnected, sub: null, tone: BannerTone.danger);
  }
  if (!online.opponentConnected && !opponentBot) {
    return (title: l.bannerOpponentOffline, sub: null, tone: BannerTone.dim);
  }
  if (isLowTime(online, me, now)) {
    final t = clockAt(online.clock, me, online.receivedAt ?? now, now);
    return (
      title: l.bannerLowTime,
      sub: l.bannerTimeLeft(formatClock(t.reserveMs)),
      tone: BannerTone.danger,
    );
  }
  return null;
}

/// Full-screen red edge glow while my time runs low (§3.2).
class LowTimeVignette extends StatelessWidget {
  const LowTimeVignette({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: active ? 1 : 0,
        duration:
            MediaQuery.of(context).disableAnimations
                ? Duration.zero
                : NardMotion.fast,
        child: CustomPaint(
          painter: _VignettePainter(c.dangerText),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _VignettePainter extends CustomPainter {
  const _VignettePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const glow = 90.0;
    final rect = Offset.zero & size;
    final glowColor = color.withValues(alpha: .38);
    final clear = color.withValues(alpha: 0);
    // Four edge gradients stand in for the inset shadow.
    for (final (r, begin, end) in [
      (
        Rect.fromLTWH(0, 0, size.width, glow),
        Alignment.topCenter,
        Alignment.bottomCenter,
      ),
      (
        Rect.fromLTWH(0, size.height - glow, size.width, glow),
        Alignment.bottomCenter,
        Alignment.topCenter,
      ),
      (
        Rect.fromLTWH(0, 0, glow, size.height),
        Alignment.centerLeft,
        Alignment.centerRight,
      ),
      (
        Rect.fromLTWH(size.width - glow, 0, glow, size.height),
        Alignment.centerRight,
        Alignment.centerLeft,
      ),
    ]) {
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: begin,
            end: end,
            colors: [glowColor, clear],
          ).createShader(r),
      );
    }
    canvas.drawRect(
      rect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: .5),
    );
  }

  @override
  bool shouldRepaint(_VignettePainter old) => old.color != color;
}

/// Card centered on the board while someone reconnects (§3.3 / §3.4).
class ReconnectCard extends StatefulWidget {
  const ReconnectCard({super.key, required this.title, this.sub});

  final String title;
  final String? sub;

  @override
  State<ReconnectCard> createState() => _ReconnectCardState();
}

class _ReconnectCardState extends State<ReconnectCard>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      unawaited(_spin.repeat());
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: 270,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(c.cardRadius),
          border: Border.all(color: c.line),
          boxShadow: c.elevation2,
        ),
        child: Row(
          children: [
            RotationTransition(
              turns: _spin,
              child: CustomPaint(
                size: const Size(26, 26),
                painter: _SpinnerPainter(track: c.line, arc: c.accent),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: NardType.body.copyWith(
                      height: 19 / 15,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  if (widget.sub != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.sub!,
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.textDim,
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.track, required this.arc});

  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.25);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
    canvas
      ..drawOval(rect, paint..color = track)
      ..drawArc(
        rect,
        -pi / 2,
        pi / 2,
        false,
        paint
          ..color = arc
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.track != track || old.arc != arc;
}

/// Idle "—" clock of the bot seat (20.2).
class ClockPlaceholder extends StatelessWidget {
  const ClockPlaceholder({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      constraints: const BoxConstraints(minWidth: 74),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: NardType.clock.copyWith(
          color: c.textDim,
          fontSize: compact ? 18 : 20,
        ),
      ),
    );
  }
}

/// 2.6 rating card of a ranked match (online.md §7.3): delta, new rating
/// counting up from the old one and the progress inside the tier band.
class RatingCard extends StatelessWidget {
  const RatingCard({super.key, required this.before, required this.after});

  final int before;
  final int after;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final delta = after - before;
    final up = delta >= 0;
    final tier = tierOf(after);
    final (light, dark) = c.tierStops(tier);
    final next = nextStep(after);
    final animate = !MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : 1, end: 1),
      duration: NardMotion.counter,
      curve: NardMotion.outExpo,
      builder: (context, t, _) {
        final shown = (before + (after - before) * t).round();
        final oldPos = tierOf(before) == tier ? bandProgress(before) : 0.0;
        final newPos = bandProgress(after);
        final base = up ? oldPos : newPos + (oldPos - newPos) * (1 - t);
        final gain = up ? oldPos + (newPos - oldPos) * t : base;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Overline(l.matchRatingLabel)),
                  Text(
                    l.signedDelta(delta),
                    style: NardType.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: up ? c.successText : c.dangerText,
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  RankBadge(tier: tier, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$shown',
                              style: NardType.labelL.copyWith(
                                fontSize: 30,
                                height: 1,
                                color: c.text,
                                fontFeatures: tabular,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.matchRatingFrom(before),
                              style: NardType.bodyS.copyWith(
                                color: c.text.withValues(alpha: .55),
                                fontFeatures: tabular,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 6,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: c.text.withValues(alpha: .1),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: gain.clamp(0, 1),
                                  child: ColoredBox(color: light),
                                ),
                                FractionallySizedBox(
                                  widthFactor: base.clamp(0, 1),
                                  child: ColoredBox(color: dark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (next != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            l.matchRatingToNext(
                              l.rankName(next.tier, next.sub),
                              next.points,
                            ),
                            style: NardType.caption.copyWith(
                              fontWeight: FontWeight.w400,
                              color: c.textDim,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
