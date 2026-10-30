import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../game/online_overlays.dart' show PeriodicBuilder;
import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart';
import '../online/reachability.dart';
import '../store/inventory.dart';
import '../store/store_providers.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'progress.dart';
import 'progress_models.dart';

/// 12.1 Daily / weekly missions, pushed inside the Home tab.
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final offline = ref.watch(offlineProvider);
    final wallet = ref.watch(inventoryProvider).value?.wallet;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OfflineBanner(text: l.offlineBanner, visible: offline),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
            child: Row(
              children: [
                Pressable(
                  onTap: () => context.pop(),
                  semanticLabel:
                      MaterialLocalizations.of(context).backButtonTooltip,
                  child: Center(
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 20,
                      color: c.text,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l.missionsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NardType.displayL.copyWith(
                      fontSize: 26,
                      color: c.text,
                    ),
                  ),
                ),
                if (wallet != null)
                  CurrencyPill(currency: Currency.coins, amount: wallet.coins),
              ],
            ),
          ),
          Expanded(child: AccountGate(builder: (_) => const _Missions())),
        ],
      ),
    );
  }
}

class _Missions extends ConsumerStatefulWidget {
  const _Missions();

  @override
  ConsumerState<_Missions> createState() => _MissionsState();
}

class _MissionsState extends ConsumerState<_Missions> {
  MissionKind _kind = MissionKind.daily;
  final _claiming = <String>{};

  Future<void> _claim(Mission m) async {
    final l = AppLocalizations.of(context);
    setState(() => _claiming.add(m.id));
    try {
      await ref.read(progressProvider.notifier).claim(m.id);
    } on ApiException catch (e) {
      if (mounted) {
        showNote(context, e.offline ? l.onlineOfflineTitle : l.errorTitle);
      }
    } finally {
      if (mounted) setState(() => _claiming.remove(m.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final state = ref.watch(progressProvider);
    final progress = state.value;
    if (progress == null) {
      if (state.hasError) {
        return OfflineMessage(onRetry: () => ref.invalidate(progressProvider));
      }
      return Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    }
    final missions = progress.of(_kind);
    final daily = progress.of(MissionKind.daily);
    final resets =
        _kind == MissionKind.daily
            ? progress.resetsDaily
            : progress.resetsWeekly;
    return RefreshIndicator(
      color: c.accent,
      onRefresh: () => ref.read(progressProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StreakCard(streak: progress.streak),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PillSegmented<MissionKind>(
              values: const [MissionKind.daily, MissionKind.weekly],
              labels: [l.missionsDaily, l.missionsWeekly],
              selected: _kind,
              onChanged: (k) => setState(() => _kind = k),
            ),
          ),
          if (resets != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: PeriodicBuilder(
                period: const Duration(seconds: 1),
                builder:
                    (_) => Text(
                      l.missionsResetsIn(
                        formatCountdown(resets.difference(DateTime.now())),
                      ),
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.text.withValues(alpha: .55),
                        fontFeatures: tabular,
                      ),
                    ),
              ),
            )
          else
            const SizedBox(height: 12),
          for (final m in missions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: MissionRow(
                mission: m,
                busy: _claiming.contains(m.id),
                onClaim: () => _claim(m),
              ),
            ),
          if (_kind == MissionKind.daily && progress.dailyBonus > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _DailyBonusRow(
                coins: progress.dailyBonus,
                done: daily.where((m) => m.completed).length,
                total: daily.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// 12.1 streak summary: title, tomorrow's reward and 7 segments.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final Streak streak;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final done = streak.current <= 0 ? 0 : Streak.cycleDay(streak.current);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l.streakCardTitle(streak.current),
                  style: NardType.title.copyWith(fontSize: 17, color: c.text),
                ),
              ),
              if (streak.rewards.isNotEmpty)
                Text(
                  l.streakTomorrow(streak.rewardFor(streak.current + 1)),
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 1; i <= 7; i++) ...[
                if (i > 1) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          i <= done ? c.accent : c.text.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One mission: diamond, name, progress, bar and the trailing pill.
class MissionRow extends StatelessWidget {
  const MissionRow({
    super.key,
    required this.mission,
    required this.onClaim,
    this.busy = false,
  });

  final Mission mission;
  final VoidCallback onClaim;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final m = mission;
    final state = m.state;
    final color = switch (state) {
      MissionState.inProgress => c.accent,
      MissionState.claimable => c.successText,
      MissionState.claimed => c.text.withValues(alpha: .3),
    };
    final Widget trailing = switch (state) {
      MissionState.inProgress => _pill(
        c,
        fill: c.surfaceSunken,
        ring: c.line,
        child: Text(
          l.missionReward(m.coins),
          style: _pillStyle.copyWith(color: c.text),
        ),
      ),
      MissionState.claimable => Pressable(
        onTap: busy ? null : onClaim,
        semanticLabel: l.missionClaim,
        child: _pill(
          c,
          fill: c.accent,
          child:
              busy
                  ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onAccent,
                    ),
                  )
                  : Text(
                    l.missionClaim,
                    style: _pillStyle.copyWith(color: c.onAccent),
                  ),
        ),
      ),
      MissionState.claimed => _pill(
        c,
        child: Icon(
          LucideIcons.check,
          size: 14,
          color: c.text.withValues(alpha: .5),
        ),
      ),
    };
    return Opacity(
      opacity: state == MissionState.claimed ? .55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: c.text.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.accent.withValues(alpha: .14)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          missionName(l, m),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state == MissionState.claimed
                            ? l.missionClaimed
                            : l.missionProgress(
                              min(m.progress, m.target),
                              m.target,
                            ),
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.text.withValues(alpha: .6),
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  NardProgressBar(
                    value: state == MissionState.inProgress ? m.fraction : 1,
                    track: c.text.withValues(alpha: .1),
                    fill: color,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }

  static final _pillStyle = NardType.bodyS.copyWith(
    fontWeight: FontWeight.w700,
    fontFeatures: tabular,
  );

  Widget _pill(
    NardColors c, {
    required Widget child,
    Color? fill,
    Color? ring,
  }) => Container(
    width: 64,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(NardRadius.pill),
      border: ring == null ? null : Border.all(color: ring),
    ),
    child: child,
  );
}

class _DailyBonusRow extends StatelessWidget {
  const _DailyBonusRow({
    required this.coins,
    required this.done,
    required this.total,
  });

  final int coins;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.accent.withValues(alpha: .4)),
            ),
            alignment: Alignment.center,
            child: const CurrencyIcon(Currency.coins, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.dailyBonusTitle(coins),
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.dailyBonusBody(done, total),
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
