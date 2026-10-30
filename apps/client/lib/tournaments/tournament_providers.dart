import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart';

import '../cosmetics/cosmetics_providers.dart' show noRetry;
import '../online/account.dart';
import '../online/game_socket.dart';
import '../online/online_game_controller.dart';
import 'tournament_models.dart';

/// 4.1 list query: tab + filters (Qısa/Uzun one at a time, Pulsuz).
class TourQuery {
  const TourQuery(this.tab, {this.variant, this.free = false});

  final TournamentTab tab;
  final Variant? variant;
  final bool free;

  @override
  bool operator ==(Object other) =>
      other is TourQuery &&
      other.tab == tab &&
      other.variant == variant &&
      other.free == free;

  @override
  int get hashCode => Object.hash(tab, variant, free);
}

final tournamentListProvider = FutureProvider.autoDispose
    .family<List<Tournament>, TourQuery>(_list, retry: noRetry);

Future<List<Tournament>> _list(Ref ref, TourQuery q) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return const [];
  final list = await ref
      .read(apiClientProvider)
      .tournaments(q.tab, variant: q.variant, free: q.free);
  if (q.tab != TournamentTab.mine) return list;
  // Mine: playing first, then by start.
  int order(Tournament t) => t.live ? 0 : 1;
  final far = DateTime(9999);
  return [...list]..sort((a, b) {
    final o = order(a).compareTo(order(b));
    if (o != 0) return o;
    return (a.startsAt ?? far).compareTo(b.startsAt ?? far);
  });
}

final tournamentDetailProvider = FutureProvider.autoDispose
    .family<TournamentDetail, String>(
      (ref, id) => ref.read(apiClientProvider).tournament(id),
      retry: noRetry,
    );

final sngTablesProvider = FutureProvider.autoDispose<List<SngTable>>(
  _sng,
  retry: noRetry,
);

Future<List<SngTable>> _sng(Ref ref) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return const [];
  return ref.read(apiClientProvider).sngTables();
}

/// 2.1 banner: the tournament I'm in that is live, or registered and
/// starting within an hour (soonest first); null otherwise or on errors.
final homeTournamentProvider = FutureProvider.autoDispose<Tournament?>(
  _homeTournament,
  retry: noRetry,
);

Future<Tournament?> _homeTournament(Ref ref) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return null;
  try {
    final mine = await ref
        .read(apiClientProvider)
        .tournaments(TournamentTab.mine);
    final now = DateTime.now();
    final candidates =
        mine.where((t) {
          if (t.live) return t.myStatus == MyTournamentStatus.playing;
          final at = t.startsAt;
          return t.registering &&
              at != null &&
              at.difference(now) < const Duration(hours: 1);
        }).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      if (a.live != b.live) return a.live ? -1 : 1;
      return (a.startsAt ?? now).compareTo(b.startsAt ?? now);
    });
    return candidates.first;
  } on Object {
    return null;
  }
}

/// Calls [refresh] every [every] (bracket changes reach clients by
/// polling, docs/api/tournaments.md); cancel it in `dispose`.
Timer pollEvery(Duration every, void Function() refresh) =>
    Timer.periodic(every, (_) => refresh());

/// Tournament traffic on the shared game-server socket: assigned-match
/// readiness (21.2) and walkovers (21.3). `tournament.ready` waits for
/// `hello` while the socket connects. Being connected already counts as
/// present for the game server.
class TournamentLive {
  const TournamentLive({
    this.ready = const {},
    this.sent = const {},
    this.walkovers = const [],
  });

  /// The latest `tournament.readyState` per match id.
  final Map<String, TournamentReadyStatePayload> ready;

  /// Match ids I sent "Hazıram" for.
  final Set<String> sent;

  /// Walkovers not yet shown.
  final List<TournamentWalkoverPayload> walkovers;

  TournamentLive copyWith({
    Map<String, TournamentReadyStatePayload>? ready,
    Set<String>? sent,
    List<TournamentWalkoverPayload>? walkovers,
  }) => TournamentLive(
    ready: ready ?? this.ready,
    sent: sent ?? this.sent,
    walkovers: walkovers ?? this.walkovers,
  );
}

class TournamentSocket extends Notifier<TournamentLive> {
  GameSocket? _bound;
  StreamSubscription<Envelope>? _sub;
  final _pending = <String>[];

  @override
  TournamentLive build() {
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return const TournamentLive();
  }

  GameSocket _socket() {
    final s = ref.read(onlineGameProvider.notifier).socket();
    if (!identical(s, _bound)) {
      unawaited(_sub?.cancel());
      _bound = s;
      _sub = s.messages.listen(_onMessage);
    }
    return s;
  }

  /// Connects so assigned matches can start and readiness arrives.
  void connect() {
    final s = _socket();
    if (s.current == SocketStatus.offline) unawaited(s.open());
  }

  /// "Hazıram" for [matchId].
  void ready(String matchId) {
    state = state.copyWith(sent: {...state.sent, matchId});
    final s = _socket();
    if (s.current == SocketStatus.online) {
      s.send(
        MessageType.tournamentReady,
        TournamentReadyPayload(matchId).toJson(),
      );
      return;
    }
    _pending.add(matchId);
    if (s.current == SocketStatus.offline) unawaited(s.open());
  }

  /// Removes a walkover once its screen was shown.
  void consumeWalkover(String matchId) =>
      state = state.copyWith(
        walkovers: [
          for (final w in state.walkovers)
            if (w.matchId != matchId) w,
        ],
      );

  void _onMessage(Envelope msg) {
    switch (msg.type) {
      case MessageType.hello:
        final s = _bound;
        if (s == null) return;
        for (final id in _pending) {
          s.send(
            MessageType.tournamentReady,
            TournamentReadyPayload(id).toJson(),
          );
        }
        _pending.clear();
      case MessageType.tournamentReadyState:
        try {
          final p = TournamentReadyStatePayload.fromJson(msg.payload);
          state = state.copyWith(ready: {...state.ready, p.matchId: p});
        } on Object {
          // Malformed: ignore.
        }
      case MessageType.tournamentWalkover:
        try {
          final p = TournamentWalkoverPayload.fromJson(msg.payload);
          state = state.copyWith(walkovers: [...state.walkovers, p]);
        } on Object {
          // Malformed: ignore.
        }
      default:
        break;
    }
  }
}

final tournamentSocketProvider =
    NotifierProvider<TournamentSocket, TournamentLive>(TournamentSocket.new);
