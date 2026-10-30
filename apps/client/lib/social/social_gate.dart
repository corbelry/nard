import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import '../online/reachability.dart';
import '../store/store_providers.dart' show OfflineMessage;
import '../theme/nard_colors.dart';
import '../ui/layout.dart';

/// Shows [builder] with the signed-in account; otherwise the sign-in
/// prompt (social copy), the offline message or a spinner.
class SocialGate extends ConsumerWidget {
  const SocialGate({super.key, required this.builder});

  final Widget Function(BuildContext context, Account account) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final state = ref.watch(accountProvider);
    final account = state.value;
    if (account != null) return builder(context, account);
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    }
    if (ref.watch(offlineProvider)) {
      return OfflineMessage(onRetry: () => ref.invalidate(accountProvider));
    }
    if (state.hasError && state.error is ApiException) {
      return MessageState(
        title: l.errorTitle,
        body: l.errorBody,
        danger: true,
        action: l.retry,
        onAction: () => ref.invalidate(accountProvider),
      );
    }
    return MessageState(
      title: l.accountNeededTitle,
      body: l.socialAccountBody,
      action: l.authSignIn,
      onAction: () => context.push('/signin'),
    );
  }
}

/// Loading / error / data for an [AsyncValue] of a social list.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final l = AppLocalizations.of(context);
    final v = value;
    if (v.hasValue) return data(v.requireValue);
    if (v.hasError) {
      final e = v.error;
      if (e is ApiException && e.offline) {
        return OfflineMessage(onRetry: onRetry);
      }
      return MessageState(
        title: l.errorTitle,
        body: l.errorBody,
        danger: true,
        action: l.retry,
        onAction: onRetry,
      );
    }
    return Center(
      child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
    );
  }
}
