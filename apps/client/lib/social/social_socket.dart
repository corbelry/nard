import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../online/account.dart';
import '../online/game_socket.dart';
import '../online/online_game_controller.dart';
import 'social_models.dart';
import 'social_providers.dart';
import 'spectate.dart';

enum RoomPhase { idle, creating, waiting, joining, matched, notFound, failed }

/// The private room I host or join (6.3).
class RoomState {
  const RoomState({
    this.phase = RoomPhase.idle,
    this.code,
    this.expiresAt,
    this.variant = Variant.shortNard,
    this.matchLength = 3,
    this.timeControl,
    this.invited,
  });

  final RoomPhase phase;
  final String? code;
  final DateTime? expiresAt;
  final Variant variant;
  final int matchLength;

  /// The room's clock (ADR-044): always set when hosting; when joining,
  /// known only from a friend challenge (null for a typed code).
  final TimeControl? timeControl;

  /// The friend challenged into this room.
  final PublicUser? invited;

  bool get hosting => phase == RoomPhase.creating || phase == RoomPhase.waiting;

  RoomState copyWith({
    RoomPhase? phase,
    String? code,
    DateTime? expiresAt,
    PublicUser? invited,
  }) => RoomState(
    phase: phase ?? this.phase,
    code: code ?? this.code,
    expiresAt: expiresAt ?? this.expiresAt,
    variant: variant,
    matchLength: matchLength,
    timeControl: timeControl,
    invited: invited ?? this.invited,
  );
}

/// An emote or phrase received in a game (2.7).
class ReceivedEmote {
  const ReceivedEmote(this.id, this.seq);

  final String id;

  /// Increases with every emote, so a repeated id shows again.
  final int seq;
}

/// The last emote from each side of the game I play or watch.
class EmoteFeed extends Notifier<Map<Side, ReceivedEmote>> {
  int _seq = 0;

  @override
  Map<Side, ReceivedEmote> build() => const {};

  void receive(Side from, String id) =>
      state = {...state, from: ReceivedEmote(id, ++_seq)};

  void clear() => state = const {};
}

final emoteFeedProvider = NotifierProvider<EmoteFeed, Map<Side, ReceivedEmote>>(
  EmoteFeed.new,
);

/// Social traffic on the game server socket (shared with
/// [OnlineGameController]): private rooms, presence, emotes, spectating.
/// Intents wait for `hello` when the socket is still connecting.
class SocialSocket extends Notifier<RoomState> {
  GameSocket? _bound;
  StreamSubscription<Envelope>? _sub;
  final _pending = <void Function(GameSocket)>[];
  String? _createId;
  String? _joinId;
  String? _spectateId;
  String? _watching;
  DateTime _lastEmote = DateTime.fromMillisecondsSinceEpoch(0);

  /// Client-side gap between two emotes (server drops sends within 2 s).
  static const emoteCooldown = Duration(seconds: 3);

  @override
  RoomState build() {
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return const RoomState();
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

  /// Starts listening to the shared socket, so emotes of a running game
  /// reach [emoteFeedProvider] (GameScreen calls it for online games).
  void attach() => _socket();

  void _run(void Function(GameSocket) action) {
    final s = _socket();
    if (s.current == SocketStatus.online) {
      action(s);
      return;
    }
    _pending.add(action);
    if (s.current == SocketStatus.offline) unawaited(s.open());
  }

  void _onMessage(Envelope msg) {
    switch (msg.type) {
      case MessageType.hello:
        final s = _bound;
        if (s == null) return;
        final actions = List.of(_pending);
        _pending.clear();
        for (final a in actions) {
          a(s);
        }
        // Resume watching after a reconnect.
        final watching = _watching;
        if (watching != null && actions.isEmpty) {
          _spectateId = s.send(MessageType.spectateJoin, {'matchId': watching});
        }
      case MessageType.roomCreated:
        if (state.phase != RoomPhase.creating) return;
        final p = RoomCodePayload.fromJson(msg.payload);
        final expires = p.expiresAt;
        state = state.copyWith(
          phase: RoomPhase.waiting,
          code: p.code,
          expiresAt:
              expires == null
                  ? DateTime.now().add(const Duration(minutes: 15))
                  : DateTime.fromMillisecondsSinceEpoch(expires),
        );
        final friend = state.invited;
        if (friend != null) unawaited(_challenge(friend, p.code));
      case MessageType.matchFound:
        ref.read(emoteFeedProvider.notifier).clear();
        if (state.phase == RoomPhase.waiting ||
            state.phase == RoomPhase.joining) {
          state = state.copyWith(phase: RoomPhase.matched);
        }
      case MessageType.presence:
        ref
            .read(presenceProvider.notifier)
            .set(PresencePayload.fromJson(msg.payload).matches);
      case MessageType.chatEmote:
        try {
          final e = EmotePayload.fromJson(msg.payload);
          final from = e.from;
          if (from != null) {
            ref.read(emoteFeedProvider.notifier).receive(from, e.id);
          }
        } on ProtocolException {
          // Unknown id from a newer server: ignore.
        }
      case MessageType.gameState:
        final watching = _watching;
        if (watching == null || msg.payload['matchId'] != watching) return;
        try {
          ref
              .read(spectatorProvider.notifier)
              .onFrame(GameStateFrame.fromJson(msg.payload));
        } on ProtocolException {
          // Ignore a malformed state; the next one replaces it.
        }
      case MessageType.error:
        if (msg.id == _joinId && state.phase == RoomPhase.joining) {
          state = state.copyWith(phase: RoomPhase.notFound);
        } else if (msg.id == _createId && state.phase == RoomPhase.creating) {
          state = state.copyWith(phase: RoomPhase.failed);
        } else if (msg.id == _spectateId) {
          _watching = null;
          ref.read(spectatorProvider.notifier).unavailable();
        }
      default:
        break;
    }
  }

  Future<void> _challenge(PublicUser friend, String code) async {
    try {
      await ref
          .read(apiClientProvider)
          .challenge(
            friend.id,
            code,
            state.variant,
            state.matchLength,
            timeControl: state.timeControl ?? TimeControl.rapid,
          );
    } on Object {
      // The code can still be shared by hand.
    }
  }

  /// Hosts a room with [timeControl] as its clock; with [invite],
  /// challenges that friend once the code arrives (6.1 "Çağır", 14.1
  /// "Oyuna çağır").
  void createRoom(
    Variant variant,
    int matchLength, {
    PublicUser? invite,
    TimeControl timeControl = TimeControl.rapid,
  }) {
    ref.read(onlineGameProvider.notifier).resetForRoom();
    state = RoomState(
      phase: RoomPhase.creating,
      variant: variant,
      matchLength: matchLength,
      timeControl: timeControl,
      invited: invite,
    );
    _run(
      (s) =>
          _createId = s.send(
            MessageType.roomCreate,
            RoomCreatePayload(
              variant: variant,
              matchLength: matchLength,
              timeControl: timeControl,
            ).toJson(),
          ),
    );
  }

  /// Joins a friend's room by its 6-character code. The settings, when
  /// known from a challenge, are only shown: the host's room decides.
  void joinRoom(
    String code, {
    Variant? variant,
    int? matchLength,
    TimeControl? timeControl,
  }) {
    ref.read(onlineGameProvider.notifier).resetForRoom();
    state = RoomState(
      phase: RoomPhase.joining,
      code: code,
      variant: variant ?? Variant.shortNard,
      matchLength: matchLength ?? 3,
      timeControl: timeControl,
    );
    _run(
      (s) =>
          _joinId = s.send(
            MessageType.roomJoin,
            RoomCodePayload(code.toUpperCase()).toJson(),
          ),
    );
  }

  void cancelRoom() {
    if (state.hosting) {
      final s = _bound;
      if (s != null && s.current == SocketStatus.online) {
        s.send(MessageType.roomCancel);
      }
    }
    _pending.clear();
    state = const RoomState();
  }

  /// Done with the room (the match started or the user left).
  void reset() => state = const RoomState();

  /// Asks who of [userIds] is in a running match (6.1 "Oyunda").
  void queryPresence(List<String> userIds) {
    if (userIds.isEmpty) return;
    _run((s) => s.send(MessageType.presenceQuery, {'userIds': userIds}));
  }

  /// Sends an emote/phrase id; false while cooling down or offline.
  bool sendEmote(String id) {
    if (!Emotes.isValid(id)) return false;
    final now = DateTime.now();
    if (now.difference(_lastEmote) < emoteCooldown) return false;
    final s = _bound ?? _socket();
    if (s.current != SocketStatus.online) return false;
    _lastEmote = now;
    s.send(MessageType.chatEmote, EmotePayload(id).toJson());
    return true;
  }

  /// Remaining cooldown before the next emote.
  Duration get emoteCooldownLeft {
    final left = emoteCooldown - DateTime.now().difference(_lastEmote);
    return left.isNegative ? Duration.zero : left;
  }

  /// Starts watching [matchId] read-only (6.4).
  void spectate(String matchId) {
    _watching = matchId;
    ref.read(emoteFeedProvider.notifier).clear();
    _run(
      (s) =>
          _spectateId = s.send(MessageType.spectateJoin, {'matchId': matchId}),
    );
  }

  /// Asks for the full state of the watched match after a delta gap.
  void resync(String matchId) {
    final s = _bound;
    if (_watching == matchId && s != null && s.current == SocketStatus.online) {
      s.send(MessageType.gameSync, {'matchId': matchId});
    }
  }

  void stopSpectating() {
    if (_watching == null) return;
    _watching = null;
    final s = _bound;
    if (s != null && s.current == SocketStatus.online) {
      s.send(MessageType.spectateLeave);
    }
  }
}

final socialSocketProvider = NotifierProvider<SocialSocket, RoomState>(
  SocialSocket.new,
);
