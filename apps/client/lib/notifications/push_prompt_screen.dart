import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../data/app_settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/extra_tokens.dart';
import 'notification_providers.dart';
import 'push_registrar.dart';

/// 16.3 Push pre-prompt, shown once before the OS permission dialog
/// (notifications.md §4). Pops true when the player turned push on.
class PushPromptScreen extends ConsumerStatefulWidget {
  const PushPromptScreen({super.key});

  @override
  ConsumerState<PushPromptScreen> createState() => _PushPromptScreenState();
}

class _PushPromptScreenState extends ConsumerState<PushPromptScreen> {
  var _busy = false;

  Future<void> _answer(bool allow) async {
    if (_busy) return;
    setState(() => _busy = true);
    // The stored settings first, or they would overwrite this answer.
    await ref.read(settingsProvider.future);
    await ref
        .read(settingsProvider.notifier)
        .change((s) => s.copyWith(pushPromptShown: true));
    var granted = false;
    if (allow) {
      final registrar = ref.read(pushRegistrarProvider);
      granted = await registrar.requestPermission() == PushStatus.granted;
      if (granted && mounted) {
        try {
          await syncPushDevice(
            ref.read(apiClientProvider),
            registrar,
            Localizations.localeOf(context).languageCode,
          );
        } on Object {
          // Registered again on the next start.
        }
      }
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop(granted);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.pushPromptBg),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PushPreview(
                          text: l.notifPromptSample1,
                          time: l.notifNow,
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: .6,
                          child: Transform.scale(
                            scale: .96,
                            child: _PushPreview(
                              text: l.notifPromptSample2,
                              time: l.notifMinutesAgo(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          l.notifPromptTitle,
                          textAlign: TextAlign.center,
                          style: NardType.displayL.copyWith(color: c.text),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.notifPromptBody,
                          textAlign: TextAlign.center,
                          style: NardType.body.copyWith(
                            height: 22 / 15,
                            color: c.text.withValues(alpha: .7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NardButton(
                      label: l.notifPromptAllow,
                      onPressed: _busy ? null : () => _answer(true),
                    ),
                    const SizedBox(height: 10),
                    NardButton(
                      label: l.notifPromptLater,
                      variant: NardButtonVariant.ghost,
                      size: NardButtonSize.m,
                      labelColor: c.text.withValues(alpha: .7),
                      onPressed: _busy ? null : () => _answer(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A lock-screen style push card (16.3).
class _PushPreview extends StatelessWidget {
  const _PushPreview({required this.text, required this.time});

  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.text.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.text.withValues(alpha: .12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: c.appIconFill,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: c.accent.withValues(alpha: .35)),
            ),
            child: Center(
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    border: Border.all(color: c.accent, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.appName,
                        style: NardType.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                          color: c.text,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: NardType.bodyS.copyWith(
                    color: c.text.withValues(alpha: .85),
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

/// Opens 16.3 once per install when the OS has not been asked yet.
Future<void> maybeShowPushPrompt(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(String path) open,
) async {
  final AppSettings settings;
  try {
    settings = await ref.read(settingsProvider.future);
  } on Object {
    return;
  }
  if (settings.pushPromptShown) return;
  if (ref.read(accountProvider).value == null) return;
  final status = await ref.read(pushRegistrarProvider).status();
  if (status != PushStatus.notDetermined || !context.mounted) return;
  await open('/push-prompt');
}
