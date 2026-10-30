import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../../cosmetics/cosmetics_text.dart' show formatCountdown;
import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../online/online_game_controller.dart';
import '../../online/online_text.dart';
import '../../online/reachability.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/buttons.dart';
import '../../ui/extra_tokens.dart';
import '../../ui/identity.dart';
import '../../ui/layout.dart';

/// Matchmaking rating band: ±50, widening by 50 every 5 s up to ±400
/// (`Matchmaker`).
int ratingBand(Duration waited) => min(400, 50 + 50 * (waited.inSeconds ~/ 5));

/// 2.4 Searching for an opponent. Moves on to 2.5 / 20.1 on `match.found`.
class SearchingScreen extends ConsumerStatefulWidget {
  const SearchingScreen({super.key});

  @override
  ConsumerState<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends ConsumerState<SearchingScreen>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  Timer? _tick;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // The match may already have been found while this screen opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onLobby(null, ref.read(lobbyProvider));
    });
  }

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
    _tick?.cancel();
    _spin.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_left) return;
    _left = true;
    ref.read(onlineGameProvider.notifier).cancelSearch();
    context.canPop() ? context.pop() : context.go('/home');
  }

  void _onLobby(Lobby? prev, Lobby next) {
    if (_left || next.phase != LobbyPhase.found) return;
    _left = true;
    context.pushReplacement('/online/vs');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Lobby>(lobbyProvider, _onLobby);
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final lobby = ref.watch(lobbyProvider);
    final account = ref.watch(accountProvider).value;
    final offline = ref.watch(offlineProvider);
    final request =
        lobby.request ??
        const QueueJoinPayload(
          variant: Variant.shortNard,
          matchLength: 1,
          mode: QueueMode.casual,
        );
    final waited = DateTime.now().difference(
      lobby.searchStartedAt ?? DateTime.now(),
    );
    final ranked = request.mode == QueueMode.ranked;
    final rating = ratingFor(account, request.variant)?.rating;
    final band = ratingBand(waited);
    final chips = [
      request.variant == Variant.shortNard ? l.variantShort : l.variantLong,
      l.formatName(request.matchLength),
      l.clockShort(request.timeControl.clock),
      if (ranked && rating != null) l.ratingRange(rating - band, rating + band),
    ];
    final tip =
        !ranked && waited.inSeconds >= 20
            ? l.searchBotSoon
            : l.searchTip(
              request.variant == Variant.longNard
                  ? l.searchTipHeadRule
                  : l.searchTipPip,
            );
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cooldown = lobby.cooldownUntil;
    if (cooldown != null) {
      return _cooldown(l, c, request, cooldown, bottom, offline);
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: c.searchBg),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                OfflineBanner(text: l.offlineBanner, visible: offline),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _Radar(
                            spin: _spin,
                            child: Avatar(
                              name: account?.name ?? '',
                              size: 120,
                              glow: true,
                              haloBlur: 40,
                            ),
                          ),
                          const SizedBox(height: 34),
                          Text(
                            l.searchTitle,
                            textAlign: TextAlign.center,
                            style: NardType.displayL.copyWith(
                              fontSize: 26,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.searchElapsed(formatDuration(waited)),
                            style: NardType.body.copyWith(
                              fontSize: 14,
                              color: c.textDim,
                              fontFeatures: tabular,
                            ),
                          ),
                          const SizedBox(height: 34),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [for (final t in chips) _InfoChip(t)],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, max(40, bottom + 6)),
                  child: Column(
                    children: [
                      Text(
                        tip,
                        textAlign: TextAlign.center,
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.text.withValues(alpha: .55),
                        ),
                      ),
                      const SizedBox(height: 12),
                      NardButton(
                        label: l.cancel,
                        variant: NardButtonVariant.outline,
                        onPressed: _cancel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The public queue is closed (abandonment penalty, ADR-042): the time
  /// left instead of the radar; "Search again" once it ran out.
  Widget _cooldown(
    AppLocalizations l,
    NardColors c,
    QueueJoinPayload request,
    DateTime until,
    double bottom,
    bool offline,
  ) {
    final left = until.difference(DateTime.now());
    final over = left <= Duration.zero;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: c.searchBg),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                OfflineBanner(text: l.offlineBanner, visible: offline),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: MessageState(
                        title: l.queueCooldownTitle,
                        body:
                            over
                                ? l.queueCooldownOverBody
                                : l.queueCooldownBody(formatCountdown(left)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, max(40, bottom + 6)),
                  child: Column(
                    children: [
                      if (over) ...[
                        NardButton(
                          label: l.queueCooldownSearch,
                          onPressed:
                              () => unawaited(
                                ref
                                    .read(onlineGameProvider.notifier)
                                    .search(request),
                              ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      NardButton(
                        label: l.back,
                        variant: NardButtonVariant.outline,
                        onPressed: _cancel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Read-only chip (h 30, pill, hairline ring).
class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NardRadius.pill),
        border: Border.all(color: c.line),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          text,
          style: NardType.caption.copyWith(
            fontWeight: FontWeight.w400,
            color: c.text,
            fontFeatures: tabular,
          ),
        ),
      ),
    );
  }
}

/// Two radar rings with a rotating brass arc around the avatar.
class _Radar extends StatelessWidget {
  const _Radar({required this.spin, required this.child});

  final Animation<double> spin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.accent.withValues(alpha: .14)),
            ),
          ),
          SizedBox(
            width: 190,
            height: 190,
            child: RotationTransition(
              turns: spin,
              child: CustomPaint(
                painter: _ArcPainter(
                  ring: c.accent.withValues(alpha: .24),
                  arc: c.accent,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.ring, required this.arc});

  final Color ring;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawOval(
        rect.deflate(.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = ring,
      )
      ..drawArc(
        rect.deflate(1),
        -3 * pi / 4,
        pi / 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = arc,
      );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.ring != ring || old.arc != arc;
}
