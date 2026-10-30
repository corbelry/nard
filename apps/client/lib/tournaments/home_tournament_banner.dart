import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../cosmetics/catalog.dart' show Currency;
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/competition.dart';
import '../ui/pressable.dart';
import 'tournament_list_screen.dart' show tournamentRoute;
import 'tournament_providers.dart';

/// 2.1 live tournament banner: the tournament I play in (or that starts
/// within the hour) → 4.3 / 4.4 / 4.2.
class HomeTournamentBanner extends ConsumerWidget {
  const HomeTournamentBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(homeTournamentProvider).value;
    if (t == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final locale = Localizations.localeOf(context).languageCode;
    final prize = priceText(l, Currency.coins, t.prizeFund);
    final at = t.startsAt;
    final meta =
        t.live || at == null
            ? l.homeTourMeta(prize)
            : l.homeTourStarts(DateFormat.Hm(locale).format(at), prize);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Pressable(
        onTap: () => context.push(tournamentRoute(t)),
        semanticLabel: t.nameFor(locale),
        child: Container(
          height: 84,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.accent.withValues(alpha: .2)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 84, child: PosterFallback()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TournamentStatusLabel(
                        text:
                            t.live
                                ? l.tourStatusLive(t.currentRound.clamp(1, 99))
                                : l.tourStatusOpen,
                        color: t.live ? c.dangerText : c.accentHi,
                        dot: t.live,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.nameFor(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.title.copyWith(
                          fontSize: 16,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.text.withValues(alpha: .64),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
