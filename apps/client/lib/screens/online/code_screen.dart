import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../online/online_text.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/background.dart';
import '../../ui/buttons.dart';
import '../../ui/fields.dart';
import '../../ui/layout.dart';
import '../../ui/pressable.dart';
import 'email_screen.dart';
import 'sign_in_screen.dart';

/// 17.3 Confirm the 6-digit code. Pops `true` when signed in.
class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key, required this.email});

  final String email;

  /// Resend cooldown (the API allows 5 codes per 10 minutes).
  static const cooldown = Duration(seconds: 60);

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  final _code = TextEditingController();
  Timer? _timer;

  /// Seconds until the code may be sent again.
  int _left = 0;
  bool _busy = false;
  String? _error;
  String? _note;
  int _shake = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _left = CodeScreen.cooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text;
    if (code.length != 6 || _busy) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _note = null;
    });
    try {
      await ref.read(accountProvider.notifier).verifyCode(widget.email, code);
      if (mounted) context.pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = authErrorText(l, e);
        _shake++;
      });
    }
  }

  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    _startCooldown();
    setState(() {
      _error = null;
      _note = null;
    });
    try {
      await ref
          .read(accountProvider.notifier)
          .requestCode(widget.email, locale);
      if (mounted) setState(() => _note = l.codeSent);
    } on Object catch (e) {
      if (mounted) setState(() => _error = authErrorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final cooling = _left > 0;
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
                      l.codeTitle,
                      style: NardType.displayL.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.codeBody(widget.email),
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        color: c.text.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 22),
                    CodeField(
                      controller: _code,
                      error: _error != null,
                      shake: _shake,
                      enabled: !_busy,
                      semanticLabel: l.codeLabel,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                        setState(() {});
                      },
                      onCompleted: (_) => _verify(),
                    ),
                    if (_error != null) ErrorLine(_error!),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:
                            cooling
                                ? Text(
                                  l.codeResendIn(
                                    formatDuration(Duration(seconds: _left)),
                                  ),
                                  style: NardType.body.copyWith(
                                    fontSize: 14,
                                    fontFeatures: tabular,
                                    color: c.text.withValues(alpha: .6),
                                  ),
                                )
                                : Pressable(
                                  onTap: _busy ? null : _resend,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 1,
                                    child: Text(
                                      l.codeResend,
                                      style: NardType.body.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: c.accentHi,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    if (_note != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                        child: Text(
                          _note!,
                          style: NardType.bodyS.copyWith(color: c.successText),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: NardButton(
                  label: l.actionConfirm,
                  onPressed: _code.text.length == 6 && !_busy ? _verify : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
