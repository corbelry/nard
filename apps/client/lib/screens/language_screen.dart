import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';

/// 9.2 Language picker (first launch, or from Settings).
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  static const _flags = {
    'az': [Color(0xFF00B5E2), Color(0xFFEF3340), Color(0xFF509E2F)],
    'tr': [Color(0xFFE30A17)],
    'ru': [Color(0xFFFFFFFF), Color(0xFF1C3578), Color(0xFFE4181C)],
    'en': [Color(0xFF1C3578), Color(0xFFE4181C)],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final settings = ref.watch(currentSettingsProvider);
    final current =
        settings.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final names = {
      'az': (l.languageNameAz, l.languageSubAz),
      'tr': (l.languageNameTr, l.languageSubTr),
      'ru': (l.languageNameRu, l.languageSubRu),
      'en': (l.languageNameEn, l.languageSubEn),
    };
    void pick(String code) {
      ref
          .read(settingsProvider.notifier)
          .change((s) => s.copyWith(locale: Locale(code)));
      if (fromSettings) context.pop();
    }

    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (fromSettings) ScreenHeader(title: l.settingsLanguage),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    fromSettings ? 8 : 44,
                    16,
                    16,
                  ),
                  children: [
                    if (!fromSettings) ...[
                      Text(
                        l.languageTitle,
                        style: NardType.displayL.copyWith(
                          fontSize: 30,
                          height: 36 / 30,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.languageSubtitle,
                        style: NardType.body.copyWith(
                          fontSize: 14,
                          color: c.textDim,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    for (final code in names.keys) ...[
                      SelectableCard(
                        selected: code == current,
                        onTap: () => pick(code),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 64,
                          child: Row(
                            children: [
                              _Flag(_flags[code]!, turkish: code == 'tr'),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      names[code]!.$1,
                                      style: NardType.labelM.copyWith(
                                        fontSize: 16,
                                        color: c.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      names[code]!.$2,
                                      style: NardType.caption.copyWith(
                                        color: c.text.withValues(alpha: .6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RadioDot(selected: code == current),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              if (!fromSettings)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: NardButton(
                    label: l.continueAction,
                    onPressed: () {
                      // Persist the shown language even if untouched.
                      ref
                          .read(settingsProvider.notifier)
                          .change((s) => s.copyWith(locale: Locale(current)));
                      context.go('/onboarding');
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

/// Simplified flag swatch (placeholder art).
class _Flag extends StatelessWidget {
  const _Flag(this.colors, {this.turkish = false});

  final List<Color> colors;
  final bool turkish;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 19,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: const Color(0x4D000000)),
    ),
    clipBehavior: Clip.antiAlias,
    child:
        turkish
            ? ColoredBox(
              color: colors.first,
              child: const Align(
                alignment: Alignment(-.16, 0),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFFFFFFFF),
                ),
              ),
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final color in colors)
                  Expanded(child: ColoredBox(color: color)),
              ],
            ),
  );
}
