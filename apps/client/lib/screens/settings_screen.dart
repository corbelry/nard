import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../app/providers.dart';
import '../data/app_settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/online_draft.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';

/// 10.2 Settings: pushed from the profile header (8.1) and the game menu.
/// [root] keeps the Phase 2 tab-root layout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.root = false});

  final bool root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final s = ref.watch(currentSettingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    void set(AppSettings Function(AppSettings) edit) => notifier.change(edit);

    Widget group(String title, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Overline(title, color: c.text.withValues(alpha: .55)),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.text.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(NardRadius.l),
              border: Border.all(color: c.accent.withValues(alpha: .14)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border:
                          i == rows.length - 1
                              ? null
                              : Border(
                                bottom: BorderSide(
                                  color: c.accent.withValues(alpha: .08),
                                ),
                              ),
                    ),
                    child: rows[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget row(String label, Widget trailing, {VoidCallback? onTap}) {
      final content = Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: NardType.body.copyWith(color: c.text)),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      );
      return onTap == null ? content : Pressable(onTap: onTap, child: content);
    }

    Widget toggle(String label, bool value, AppSettings Function(bool) edit) =>
        row(
          label,
          NardSwitch(
            value: value,
            compact: true,
            semanticLabel: label,
            onChanged: (v) => set((_) => edit(v)),
          ),
        );

    Widget value(String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: NardType.body.copyWith(
            fontSize: 14,
            color: c.text.withValues(alpha: .6),
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          LucideIcons.chevronRight,
          size: 14,
          color: c.text.withValues(alpha: .5),
        ),
      ],
    );

    String speedName(AnimationSpeed v) => switch (v) {
      AnimationSpeed.slow => l.animationSpeedSlow,
      AnimationSpeed.normal => l.animationSpeedNormal,
      AnimationSpeed.fast => l.animationSpeedFast,
    };

    Future<void> pickSpeed() async {
      final picked = await showNardSheet<AnimationSpeed>(
        context,
        builder:
            (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetTitle(l.settingsAnimationSpeed),
                const SizedBox(height: 12),
                for (final v in AnimationSpeed.values) ...[
                  SelectableCard(
                    selected: v == s.animationSpeed,
                    onTap: () => Navigator.of(ctx).pop(v),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            speedName(v),
                            style: NardType.labelM.copyWith(color: c.text),
                          ),
                        ),
                        RadioDot(selected: v == s.animationSpeed),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
      );
      if (picked != null) set((x) => x.copyWith(animationSpeed: picked));
    }

    final langName = switch (Localizations.localeOf(context).languageCode) {
      'az' => l.languageNameAz,
      'tr' => l.languageNameTr,
      'ru' => l.languageNameRu,
      _ => l.languageNameEn,
    };

    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        group(l.settingsGroupGame, [
          toggle(
            l.settingsConfirmMove,
            s.confirmMoves,
            (v) => s.copyWith(confirmMoves: v),
          ),
          toggle(
            l.settingsAutoRoll,
            s.autoRoll,
            (v) => s.copyWith(autoRoll: v),
          ),
          toggle(
            l.settingsShowLegalMoves,
            s.showLegalMoves,
            (v) => s.copyWith(showLegalMoves: v),
          ),
          toggle(
            l.settingsPipCount,
            s.showPipCount,
            (v) => s.copyWith(showPipCount: v),
          ),
          row(
            l.settingsAnimationSpeed,
            value(speedName(s.animationSpeed)),
            onTap: pickSpeed,
          ),
        ]),
        group(l.settingsGroupAccessibility, [
          toggle(
            l.settingsColorBlind,
            s.colorBlind,
            (v) => s.copyWith(colorBlind: v),
          ),
          toggle(
            l.settingsLargePips,
            s.largePips,
            (v) => s.copyWith(largePips: v),
          ),
          toggle(
            l.settingsReduceMotion,
            s.reduceMotion,
            (v) => s.copyWith(reduceMotion: v),
          ),
        ]),
        group(l.settingsGroupGeneral, [
          row(
            l.settingsAccountPrivacy,
            value(''),
            onTap: () async {
              if (await ensureSignedIn(context, ref) && context.mounted) {
                await context.push('/account');
              }
            },
          ),
          toggle(l.settingsSound, s.sound, (v) => s.copyWith(sound: v)),
          toggle(l.settingsHaptics, s.haptics, (v) => s.copyWith(haptics: v)),
          row(
            l.settingsLanguage,
            value(langName),
            onTap: () => context.push('/language?settings=1'),
          ),
          row(
            l.settingsReplays,
            value(''),
            onTap: () => context.push('/replays'),
          ),
          row(
            l.settingsLesson,
            value(''),
            onTap: () => context.push('/lesson'),
          ),
        ]),
        Center(
          child: Text(
            l.settingsAbout('0.1.0'),
            style: NardType.caption.copyWith(
              color: c.text.withValues(alpha: .4),
            ),
          ),
        ),
      ],
    );

    final content = SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (root)
            RootTitle(l.settingsTitle)
          else
            ScreenHeader(title: l.settingsTitle),
          Expanded(child: list),
        ],
      ),
    );
    return root ? content : Scaffold(body: NardBackground(child: content));
  }
}
