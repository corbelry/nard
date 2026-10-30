import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../app/setup_draft.dart';
import '../game/game_controller.dart';
import '../l10n/gen/app_localizations.dart';
import '../notifications/inbox_bell.dart';
import '../online/account.dart';
import '../online/online_draft.dart';
import '../online/online_text.dart';
import '../online/rank.dart';
import '../online/reachability.dart';
import '../progression/home_progress.dart';
import '../puzzles/home_puzzle_card.dart';
import '../seasons/home_season.dart';
import '../social/room_screen.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../tournaments/home_tournament_banner.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/extra_tokens.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'ai_level_screen.dart';

/// 2.1 Home: profile row (signed in), hero card with the quick game vs the
/// computer, and the mode tiles incl. online casual / ranked (§7.1).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final setup = ref.watch(setupDraftProvider);
    final variantUpper =
        setup.variant == Variant.shortNard
            ? l.variantShortUpper
            : l.variantLongUpper;
    final format =
        setup.matchLength <= 1
            ? l.oneGameUpper
            : l.matchToPointsUpper(setup.matchLength);
    final other =
        setup.variant == Variant.shortNard ? l.variantLong : l.variantShort;

    void play() {
      ref.read(setupDraftProvider.notifier).remember(setup);
      ref.read(gameControllerProvider.notifier).start(setup);
      context.push('/game');
    }

    final account = ref.watch(accountProvider).value;
    final offline = ref.watch(offlineProvider);

    Future<void> online(QueueMode mode) async {
      if (!await ensureSignedIn(context, ref) || !context.mounted) return;
      final draft = ref.read(onlineDraftProvider);
      ref.read(onlineDraftProvider.notifier).set(draft.copyWith(mode: mode));
      await context.push('/online/setup');
    }

    void toggleVariant() {
      final draft = ref.read(setupDraftProvider.notifier);
      draft.edit(
        (s) => s.copyWith(
          variant:
              s.variant == Variant.shortNard
                  ? Variant.longNard
                  : Variant.shortNard,
        ),
      );
      draft.remember(ref.read(setupDraftProvider));
    }

    final rating = ratingFor(account, setup.variant);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        children: [
          OfflineBanner(text: l.offlineBanner, visible: offline),
          if (account != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onTap: () => context.go('/profile'),
                      semanticLabel: account.name,
                      child: Row(
                        children: [
                          Avatar(name: account.name, size: 48),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: NardType.labelM.copyWith(
                                    fontSize: 16,
                                    color: c.text,
                                  ),
                                ),
                                if (rating != null) ...[
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      RankBadge(
                                        tier: tierNamed(
                                          rating.tier,
                                          rating.rating,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l.rankMeta(rating.rating),
                                        style: NardType.caption.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: c.textDim,
                                          fontFeatures: tabular,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const HomeLevelLine(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Inbox (16.2): bell + unread badge; polls while shown.
                  const InboxBell(),
                ],
              ),
            ),
          if (account != null) const HomeCurrencyRow(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nard',
                        style: NardType.displayL.copyWith(color: c.text),
                      ),
                      TextSpan(
                        text: 'Arena',
                        style: NardType.displayL.copyWith(
                          color: c.accent,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: c.surfaceRaised,
                    borderRadius: BorderRadius.circular(NardRadius.xl),
                    border: Border.all(color: c.accent.withValues(alpha: .35)),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.accent.withValues(alpha: .22),
                          c.accent.withValues(alpha: .04),
                        ],
                        stops: const [0, .6],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          width: 160,
                          height: 160,
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback:
                                (r) => const RadialGradient(
                                  colors: [Colors.white, Colors.transparent],
                                  stops: [0, .7],
                                ).createShader(r),
                            child: CustomPaint(
                              painter: LatticePainter(
                                color: c.accent.withValues(alpha: .12),
                                spacing: 16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Overline(l.homeHeroMeta(variantUpper, format)),
                              const SizedBox(height: 6),
                              Text(
                                l.homeHeroMode(aiLevelName(l, setup.level)),
                                style: NardType.labelM.copyWith(
                                  color: c.text.withValues(alpha: .85),
                                ),
                              ),
                              const SizedBox(height: 16),
                              NardButton(
                                label: l.homePlay,
                                size: NardButtonSize.hero,
                                onPressed: play,
                              ),
                              const SizedBox(height: 4),
                              Pressable(
                                onTap: toggleVariant,
                                child: Row(
                                  children: [
                                    Text(
                                      l.homeChangeMode,
                                      style: NardType.caption.copyWith(
                                        color: c.textDim,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      l.homeOtherVariant(other),
                                      style: NardType.caption.copyWith(
                                        color: c.accentHi,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: max(
                    .6,
                    (MediaQuery.sizeOf(context).width - 56) / 4 / 74,
                  ),
                  children: [
                    _ModeTile(
                      icon: LucideIcons.dice3,
                      label: l.modeCasual,
                      enabled: !offline,
                      onTap: () => online(QueueMode.casual),
                    ),
                    _ModeTile(
                      icon: LucideIcons.trophy,
                      label: l.modeRanked,
                      enabled: !offline,
                      onTap: () => online(QueueMode.ranked),
                    ),
                    _ModeTile(
                      icon: LucideIcons.lock,
                      label: l.modePrivateRoom,
                      enabled: !offline,
                      onTap: () async {
                        if (!await ensureSignedIn(context, ref) ||
                            !context.mounted) {
                          return;
                        }
                        await showRoomChooser(context, ref);
                      },
                    ),
                    _ModeTile(
                      icon: LucideIcons.users,
                      label: l.modeFriends,
                      enabled: !offline,
                      onTap: () async {
                        if (!await ensureSignedIn(context, ref) ||
                            !context.mounted) {
                          return;
                        }
                        await context.push('/friends');
                      },
                    ),
                    _ModeTile(
                      icon: LucideIcons.monitor,
                      label: l.modeComputer,
                      onTap: () => context.push('/setup'),
                    ),
                    _ModeTile(
                      icon: LucideIcons.smartphone,
                      label: l.modeSameDevice,
                      onTap: () => context.push('/hotseat'),
                    ),
                    _ModeTile(
                      icon: LucideIcons.graduationCap,
                      label: l.modeLesson,
                      onTap: () => context.push('/lesson'),
                    ),
                    _ModeTile(
                      icon: LucideIcons.history,
                      label: l.modeReplays,
                      onTap: () => context.push('/replays'),
                    ),
                  ],
                ),
                if (account != null) ...[
                  const HomeTournamentBanner(),
                  const SizedBox(height: 8),
                  const HomeSeasonPrompt(),
                  const HomeProgressRow(),
                  const SizedBox(height: 8),
                  HomePuzzleCard(enabled: !offline),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Online tiles fade and stop reacting while offline (§7.1).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: enabled ? onTap : null,
      semanticLabel: label,
      child: AnimatedOpacity(
        duration: NardMotion.fast,
        opacity: enabled ? 1 : .55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: c.tile,
            borderRadius: BorderRadius.circular(c.cardRadius),
            border: Border.all(color: c.tileRing),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: c.accent),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NardType.micro.copyWith(color: c.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
