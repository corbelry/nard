import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/background.dart';
import '../../ui/layout.dart';
import '../../ui/pressable.dart';
import 'account_sheets.dart';

/// 15.1 Account & privacy (Phase 3 rows only; privacy toggles are Phase 5).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final account = ref.watch(accountProvider).value;

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

    Widget row(
      String label, {
      String value = '',
      Color? color,
      required VoidCallback? onTap,
    }) => Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: NardType.body.copyWith(color: color ?? c.text),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NardType.body.copyWith(
                  fontSize: 14,
                  color: c.text.withValues(alpha: .6),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: c.text.withValues(alpha: .5),
            ),
          ],
        ),
      ),
    );

    Future<void> delete() async {
      final deleted = await showDeleteSheet(context);
      if (deleted == true && context.mounted) {
        context.go('/home');
        unawaited(context.push('/signin'));
      }
    }

    final email = account?.email;
    return Scaffold(
      body: NardBackground(
        band: false,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.settingsAccountPrivacy, bare: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    group(l.accountGroupAccount, [
                      row(
                        l.accountEmail,
                        value: email ?? l.accountEmailAdd,
                        // Guests link an e-mail with the same code flow.
                        onTap:
                            email == null
                                ? () => context.push('/signin/email')
                                : null,
                      ),
                      row(
                        l.accountNickname,
                        value: account?.name ?? '',
                        onTap:
                            account == null
                                ? null
                                : () => showRenameSheet(context),
                      ),
                      row(
                        l.accountSignOut,
                        onTap:
                            account == null
                                ? null
                                : () async {
                                  await ref
                                      .read(accountProvider.notifier)
                                      .signOut();
                                  if (context.mounted) context.go('/home');
                                },
                      ),
                    ]),
                    group(l.accountGroupData, [
                      row(
                        l.accountExport,
                        onTap:
                            account == null
                                ? null
                                : () => showExportSheet(context),
                      ),
                      row(
                        l.accountDelete,
                        color: c.dangerText,
                        onTap: account == null ? null : delete,
                      ),
                    ]),
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
