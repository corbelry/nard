import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/cosmetics_providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import '../online/reachability.dart';
import '../theme/nard_colors.dart';
import '../ui/layout.dart';
import 'store_models.dart';

/// 7.3 offers (featured + daily picks); null while signed out.
final storeOffersProvider = FutureProvider<StoreOffers?>(
  _offers,
  retry: noRetry,
);

Future<StoreOffers?> _offers(Ref ref) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return null;
  return ref.read(apiClientProvider).offers();
}

/// Yaqut packs; null while signed out.
final gemProductsProvider = FutureProvider<GemProducts?>(
  _products,
  retry: noRetry,
);

Future<GemProducts?> _products(Ref ref) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return null;
  return ref.read(apiClientProvider).products();
}

/// Shows [builder] once signed in; otherwise the sign-in prompt, the
/// offline message or a spinner (store, locker, missions, achievements).
class AccountGate extends ConsumerWidget {
  const AccountGate({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final state = ref.watch(accountProvider);
    if (state.value != null) return builder(context);
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
      body: l.accountNeededBody,
      action: l.authSignIn,
      onAction: () => context.push('/signin'),
    );
  }
}

/// The "online play unavailable" message with a retry button.
class OfflineMessage extends StatelessWidget {
  const OfflineMessage({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MessageState(
      title: l.onlineOfflineTitle,
      body: l.onlineOfflineBody,
      danger: true,
      action: l.retry,
      onAction: onRetry,
    );
  }
}

/// A short message at the bottom of the screen.
void showNote(BuildContext context, String text) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
