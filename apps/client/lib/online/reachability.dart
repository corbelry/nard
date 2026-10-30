import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account.dart';
import 'api_client.dart';

/// Whether the API answers (11.1 offline banner). Follows every request of
/// [ApiClient]; while unreachable it probes every 15 s and reloads the
/// account once the server is back.
class ReachabilityNotifier extends Notifier<bool> {
  Timer? _probe;

  static const probeEvery = Duration(seconds: 15);

  @override
  bool build() {
    final api = ref.watch(apiClientProvider);
    final sub = api.reachability.listen(_changed);
    ref.onDispose(() {
      _probe?.cancel();
      unawaited(sub.cancel());
    });
    if (!api.reachable) _startProbe(api);
    return api.reachable;
  }

  void _changed(bool reachable) {
    final api = ref.read(apiClientProvider);
    if (reachable) {
      _probe?.cancel();
      _probe = null;
      final account = ref.read(accountProvider);
      if (account.hasError) ref.invalidate(accountProvider);
    } else {
      _startProbe(api);
    }
    state = reachable;
  }

  void _startProbe(ApiClient api) {
    _probe ??= Timer.periodic(probeEvery, (_) => unawaited(api.probe()));
  }
}

final reachabilityProvider = NotifierProvider<ReachabilityNotifier, bool>(
  ReachabilityNotifier.new,
);

/// True while online features are unavailable: the API is unreachable or
/// the account could not be loaded for lack of a connection.
final offlineProvider = Provider<bool>((ref) {
  if (!ref.watch(reachabilityProvider)) return true;
  final error = ref.watch(accountProvider).error;
  return error is ApiException && error.offline;
});
