import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../online/api_client.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/buttons.dart';
import '../../ui/extra_tokens.dart';
import '../../ui/layout.dart';

/// Message for an auth API failure (online.md §1.4).
String authErrorText(AppLocalizations l, Object error) {
  if (error is! ApiException) return l.errorTitle;
  if (error.offline) return l.authOffline;
  return switch (error.code) {
    'code_invalid' => l.codeInvalid,
    'code_expired' => l.codeExpired,
    'provider_disabled' || 'not_implemented' => l.authProviderUnavailable,
    'validation' => l.emailInvalid,
    'banned' => l.authBanned,
    _ when error.status == 429 => l.authTooManyTries,
    _ => l.errorTitle,
  };
}

enum _Method { apple, google, guest }

/// 9.4 / 17.1 Sign-in choice. Pops `true` once signed in, so callers can
/// continue (online play, profile).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  _Method? _busy;
  String? _error;

  Future<void> _run(_Method method) async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final account = ref.read(accountProvider.notifier);
    setState(() {
      _busy = method;
      _error = null;
    });
    try {
      switch (method) {
        case _Method.apple:
          await account.signInWithProvider('apple');
        case _Method.google:
          await account.signInWithProvider('google');
        case _Method.guest:
          await account.signInAsGuest(locale);
      }
      if (mounted) context.pop(true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = authErrorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _email() async {
    final ok = await context.push<bool>('/signin/email');
    if (ok == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final idle = _busy == null;
    final legal = l.authLegal('\u0001', '\u0002');
    final legalStyle = NardType.caption.copyWith(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w400,
      color: c.text.withValues(alpha: .5),
    );
    final linkStyle = legalStyle.copyWith(color: c.accentHi);
    // Links are styled in place of the placeholders (no URLs yet).
    final spans = <InlineSpan>[];
    var buffer = StringBuffer();
    for (final ch in legal.split('')) {
      if (ch == '\u0001' || ch == '\u0002') {
        spans
          ..add(TextSpan(text: buffer.toString()))
          ..add(
            TextSpan(
              text: ch == '\u0001' ? l.authTerms : l.authPrivacy,
              style: linkStyle,
            ),
          );
        buffer = StringBuffer();
      } else {
        buffer.write(ch);
      }
    }
    spans.add(TextSpan(text: buffer.toString()));
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.authBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ScreenHeader(
                  title: '',
                  bare: true,
                  onBack: () => context.pop(false),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const _Mark(),
                        const SizedBox(height: 16),
                        Text(
                          l.authWelcomeTitle,
                          textAlign: TextAlign.center,
                          style: NardType.displayL.copyWith(
                            fontSize: 30,
                            height: 36 / 30,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.authWelcomeBody,
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
                padding: EdgeInsets.fromLTRB(16, 0, 16, max(40, bottom + 6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: NardType.bodyS.copyWith(
                            height: 18 / 13,
                            color: c.dangerText,
                          ),
                        ),
                      ),
                    AuthButton(
                      label: l.authApple,
                      light: true,
                      busy: _busy == _Method.apple,
                      leading: Icon(
                        LucideIcons.apple,
                        size: 18,
                        color: c.appleText,
                      ),
                      onPressed: idle ? () => _run(_Method.apple) : null,
                    ),
                    const SizedBox(height: 10),
                    AuthButton(
                      label: l.authGoogle,
                      busy: _busy == _Method.google,
                      leading: const _GoogleMark(),
                      onPressed: idle ? () => _run(_Method.google) : null,
                    ),
                    const SizedBox(height: 10),
                    AuthButton(
                      label: l.authEmail,
                      leading: Icon(LucideIcons.mail, size: 18, color: c.text),
                      onPressed: idle ? _email : null,
                    ),
                    const SizedBox(height: 10),
                    _busy == _Method.guest
                        ? SizedBox(
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.accentHi,
                              ),
                            ),
                          ),
                        )
                        : NardButton(
                          label: l.authGuest,
                          variant: NardButtonVariant.ghost,
                          size: NardButtonSize.m,
                          labelColor: c.accentHi,
                          labelStyle: NardType.labelM,
                          onPressed: idle ? () => _run(_Method.guest) : null,
                        ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(style: legalStyle, children: spans),
                      textAlign: TextAlign.center,
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

/// The splash mark at 0.69×: rotated square with a brass border and core.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return SizedBox(
      width: 64,
      height: 64,
      child: Center(
        child: Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: c.accent, width: 5),
            ),
            alignment: Alignment.center,
            child: Container(width: 11, height: 11, color: c.accentHi),
          ),
        ),
      ),
    );
  }
}

/// Placeholder "G" mark (mock: conic of the four brand colours) until the
/// brand asset is added with the Google sign-in keys.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  static const _brand = [
    Color(0xFFEA4335),
    Color(0xFFFBBC05),
    Color(0xFF34A853),
    Color(0xFF4285F4),
    Color(0xFFEA4335),
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(colors: _brand),
    ),
  );
}
