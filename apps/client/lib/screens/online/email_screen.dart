import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/background.dart';
import '../../ui/buttons.dart';
import '../../ui/fields.dart';
import '../../ui/layout.dart';
import 'sign_in_screen.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

/// 17.2 Enter e-mail. Pops `true` after the code was confirmed (17.3).
class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!isValidEmail(email) || _busy) return;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountProvider.notifier).requestCode(email, locale);
      if (!mounted) return;
      setState(() => _busy = false);
      final ok = await context.push<bool>(
        Uri(path: '/signin/code', queryParameters: {'email': email}).toString(),
      );
      if (ok == true && mounted) context.pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = authErrorText(l, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final valid = isValidEmail(_email.text);
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(title: '', bare: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  children: [
                    Text(
                      l.emailTitle,
                      style: NardType.displayL.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.emailBody,
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        color: c.text.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 22),
                    AutofillGroup(
                      child: NardTextField(
                        controller: _email,
                        label: l.emailLabel,
                        autofocus: true,
                        error: _error != null,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.send,
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    if (_error != null) ErrorLine(_error!),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: NardButton(
                  label: l.emailSend,
                  onPressed: valid && !_busy ? _send : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error under a field (online.md §1.4).
class ErrorLine extends StatelessWidget {
  const ErrorLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
    child: Semantics(
      liveRegion: true,
      child: Text(
        text,
        style: NardType.bodyS.copyWith(color: context.nard.dangerText),
      ),
    ),
  );
}
