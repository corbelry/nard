import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';

/// 2.1 daily puzzle entry (tournaments.md §12 proposal) → 13.1.
class HomePuzzleCard extends StatelessWidget {
  const HomePuzzleCard({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Pressable(
      onTap: enabled ? () => context.push('/puzzles?daily=1') : null,
      semanticLabel: l.puzzleDailyTitle,
      child: AnimatedOpacity(
        duration: NardMotion.fast,
        opacity: enabled ? 1 : .55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: c.tile,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.tileRing),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.puzzle, size: 22, color: c.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Overline(l.homePuzzleOverline),
                    const SizedBox(height: 4),
                    Text(
                      l.puzzlePrompt,
                      style: NardType.bodyS.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.text,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: c.textDim),
            ],
          ),
        ),
      ),
    );
  }
}
