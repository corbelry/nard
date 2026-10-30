import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_ai/nard_ai.dart';

import '../app/setup_draft.dart';
import '../game/game_controller.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';

String aiLevelName(AppLocalizations l, BotLevel level) => switch (level) {
  BotLevel.beginner => l.aiLevelBeginner,
  BotLevel.easy => l.aiLevelAmateur,
  BotLevel.medium => l.aiLevelMedium,
  BotLevel.hard => l.aiLevelStrong,
  BotLevel.expert => l.aiLevelMaster,
  BotLevel.master => l.aiLevelGrandmaster,
};

/// 2.3 Vs computer: AI level. Usta and Qrossmeyster are locked (ADR-019).
class AiLevelScreen extends ConsumerWidget {
  const AiLevelScreen({super.key});

  static const locked = {BotLevel.expert, BotLevel.master};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final setup = ref.watch(setupDraftProvider);
    final draft = ref.read(setupDraftProvider.notifier);
    String desc(BotLevel level) => switch (level) {
      BotLevel.beginner => l.aiLevelBeginnerDesc,
      BotLevel.easy => l.aiLevelAmateurDesc,
      BotLevel.medium => l.aiLevelMediumDesc,
      BotLevel.hard => l.aiLevelStrongDesc,
      BotLevel.expert => l.aiLevelMasterDesc,
      BotLevel.master => l.aiLevelGrandmasterDesc,
    };
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.aiTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  children: [
                    for (final level in BotLevel.values) ...[
                      SelectableCard(
                        selected: setup.level == level,
                        enabled: !locked.contains(level),
                        onTap:
                            () => draft.edit((s) => s.copyWith(level: level)),
                        child: Row(
                          children: [
                            _Meter(level.index),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    aiLevelName(l, level),
                                    style: NardType.labelM.copyWith(
                                      fontSize: 16,
                                      color: c.text,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    desc(level),
                                    style: NardType.caption.copyWith(
                                      color: c.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (locked.contains(level))
                              Container(
                                height: 26,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x4D000000),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: c.accent.withValues(alpha: .3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.lock,
                                      size: 12,
                                      color: c.text,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l.comingSoon,
                                      style: NardType.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: c.text.withValues(alpha: .8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: NardButton(
                  label: l.aiStart(aiLevelName(l, setup.level)),
                  onPressed: () {
                    final s = ref.read(setupDraftProvider);
                    draft.remember(s);
                    ref.read(gameControllerProvider.notifier).start(s);
                    context.go('/home');
                    context.push('/game');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six-bar strength meter.
class _Meter extends StatelessWidget {
  const _Meter(this.level);

  final int level;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return SizedBox(
      width: 62,
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var k = 0; k < 6; k++) ...[
            if (k > 0) const SizedBox(width: 3),
            Container(
              width: 7,
              height: 8.0 + 4 * k,
              decoration: BoxDecoration(
                color: k <= level ? c.accent : c.text.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
