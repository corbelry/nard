import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_theme.dart';
import 'providers.dart';
import 'router.dart';

class NardApp extends ConsumerWidget {
  const NardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentSettingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
      debugShowCheckedModeBanner: false,
      theme: NardTheme.build(NardColors.defaultTheme),
      routerConfig: ref.watch(routerProvider),
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Unsupported device languages fall back to English (ADR-018).
      localeListResolutionCallback: (locales, supported) {
        for (final locale in locales ?? const <Locale>[]) {
          for (final s in supported) {
            if (s.languageCode == locale.languageCode) return s;
          }
        }
        return const Locale('en');
      },
      builder:
          (context, child) => MediaQuery(
            // Respect the OS reduce-motion flag as well as the app setting.
            data: MediaQuery.of(context).copyWith(
              disableAnimations:
                  MediaQuery.of(context).disableAnimations ||
                  settings.reduceMotion,
            ),
            child: child!,
          ),
    );
  }
}
