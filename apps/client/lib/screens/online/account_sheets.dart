import 'dart:async';

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
import '../../ui/fields.dart';
import '../../ui/layout.dart';
import 'email_screen.dart';
import 'sign_in_screen.dart';

final _namePattern = RegExp(r'^[\p{L}\p{N}_]{3,20}$', unicode: true);

/// The API's name rule (3–20 letters, digits or _).
bool isValidName(String name) => _namePattern.hasMatch(name.trim());

/// Case-folds for the delete confirmation so az/tr dotted and dotless I
/// compare equal whatever the keyboard produced (online.md §12.6).
String foldConfirm(String s) =>
    s.trim().replaceAll(RegExp('[İIıi]'), 'i').toLowerCase();

/// Rename sheet (8.1 edit / 15.1 Oyunçu adı).
Future<void> showRenameSheet(BuildContext context) =>
    showNardSheet<void>(context, builder: (_) => const _RenameBody());

class _RenameBody extends ConsumerStatefulWidget {
  const _RenameBody();

  @override
  ConsumerState<_RenameBody> createState() => _RenameBodyState();
}

class _RenameBodyState extends ConsumerState<_RenameBody> {
  late final _name = TextEditingController(
    text: ref.read(accountProvider).value?.name ?? '',
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!isValidName(_name.text)) {
      setState(() => _error = l.nameInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountProvider.notifier).rename(_name.text.trim());
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            e is ApiException && e.status == 422
                ? l.nameInvalid
                : authErrorText(l, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l.profileEdit),
          const SizedBox(height: 14),
          NardTextField(
            controller: _name,
            label: l.accountNickname,
            autofocus: true,
            maxLength: 20,
            error: _error != null,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ErrorLine(_error!),
          const SizedBox(height: 18),
          NardButton(label: l.actionSave, onPressed: _busy ? null : _save),
        ],
      ),
    );
  }
}

/// 15.2 Export my data: the API e-mails a ZIP to the account address;
/// accounts without one link an e-mail first (QUESTIONS #17).
Future<void> showExportSheet(BuildContext context) =>
    showNardSheet<void>(context, builder: (_) => const _ExportBody());

class _ExportBody extends ConsumerStatefulWidget {
  const _ExportBody();

  @override
  ConsumerState<_ExportBody> createState() => _ExportBodyState();
}

class _ExportBodyState extends ConsumerState<_ExportBody> {
  bool _busy = false;
  String? _sentTo;
  String? _error;

  Future<void> _start() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final email = await ref.read(apiClientProvider).requestExport();
      if (mounted) setState(() => _sentTo = email);
    } on Object catch (e) {
      if (mounted) setState(() => _error = authErrorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final account = ref.watch(accountProvider).value;
    final email = account?.email;
    Widget row(
      String label,
      String? trailing, {
      bool last = false,
    }) => Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border:
            last
                ? null
                : Border(
                  bottom: BorderSide(color: c.accent.withValues(alpha: .08)),
                ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: c.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(LucideIcons.check, size: 14, color: c.onAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: NardType.body.copyWith(color: c.text)),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: NardType.caption.copyWith(
                fontWeight: FontWeight.w400,
                color: c.text.withValues(alpha: .55),
              ),
            ),
        ],
      ),
    );
    final sentTo = _sentTo;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          SheetTitle(l.exportTitle),
          const SizedBox(height: 14),
          Text(
            email == null ? l.exportNeedsEmail : l.exportBody(email),
            style: NardType.body.copyWith(
              fontSize: 14,
              color: c.text.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: c.text.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(NardRadius.l),
              border: Border.all(color: c.accent.withValues(alpha: .14)),
            ),
            child: Column(
              children: [
                row(l.exportProfile, null),
                // No count: ratings count rated matches only, the ZIP has all.
                row(l.exportGames, null),
                row(l.exportPurchases, null),
                row(l.exportSocial, null, last: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sentTo == null ? l.exportFormat : l.exportSent(sentTo),
                    style: NardType.bodyS.copyWith(
                      color:
                          sentTo == null
                              ? c.text.withValues(alpha: .6)
                              : c.successText,
                    ),
                  ),
                ),
                Text(
                  l.exportFormatValue,
                  style: NardType.mono.copyWith(
                    fontSize: 13,
                    color: c.text.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ErrorLine(_error!),
          const SizedBox(height: 18),
          if (sentTo != null)
            NardButton(
              label: l.close,
              onPressed: () => Navigator.of(context).pop(),
            )
          else if (email == null)
            NardButton(
              label: l.exportLinkEmail,
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                unawaited(router.push('/signin/email'));
              },
            )
          else
            NardButton(label: l.exportStart, onPressed: _busy ? null : _start),
          if (sentTo == null) ...[
            const SizedBox(height: 10),
            NardButton(
              label: l.cancel,
              variant: NardButtonVariant.ghost,
              size: NardButtonSize.m,
              labelColor: c.text.withValues(alpha: .7),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }
}

/// 15.3 Delete account. Returns true once the account is deleted.
Future<bool?> showDeleteSheet(BuildContext context) =>
    showNardSheet<bool>(context, builder: (_) => const _DeleteBody());

class _DeleteBody extends ConsumerStatefulWidget {
  const _DeleteBody();

  @override
  ConsumerState<_DeleteBody> createState() => _DeleteBodyState();
}

class _DeleteBodyState extends ConsumerState<_DeleteBody> {
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountProvider.notifier).deleteAccount();
      if (mounted) Navigator.of(context).pop(true);
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
    final ratings = ref.watch(accountProvider).value?.ratings.values;
    final best =
        ratings == null || ratings.isEmpty
            ? null
            : ratings.map((r) => r.rating).reduce((a, b) => a > b ? a : b);
    final word = l.deleteConfirmWord;
    final matches = foldConfirm(_confirm.text) == foldConfirm(word);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.dangerText.withValues(alpha: .14),
                  border: Border.all(color: c.dangerText.withValues(alpha: .5)),
                ),
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 24,
                  color: c.dangerText,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SheetTitle(l.deleteTitle),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Transform.rotate(
                    angle: .785398,
                    child: Container(width: 6, height: 6, color: c.dangerText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    best == null
                        ? l.deleteItemHistory
                        : l.deleteItemRating(best),
                    style: NardType.body.copyWith(
                      fontSize: 14,
                      color: c.text.withValues(alpha: .8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l.deleteIrreversible,
              style: NardType.bodyS.copyWith(
                height: 19 / 13,
                color: c.text.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: 14),
            NardTextField(
              controller: _confirm,
              label: l.deleteConfirmLabel(word),
              height: 50,
              danger: true,
              textCapitalization: TextCapitalization.characters,
              style: NardType.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_error != null) ErrorLine(_error!),
            const SizedBox(height: 18),
            NardButton(
              label: l.accountDelete,
              variant: NardButtonVariant.danger,
              onPressed: matches && !_busy ? _delete : null,
            ),
            const SizedBox(height: 10),
            NardButton(
              label: l.cancel,
              variant: NardButtonVariant.ghost,
              size: NardButtonSize.m,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
