import 'package:nard_core/nard_core.dart';

import 'messages.dart';
import 'read.dart';

/// API → game server, `POST /internal/tournament-matches` (signed like
/// results, `X-Nard-Signature`): a pairing to play. The game server starts
/// the match once both players are present and reports a walkover (or a
/// [TournamentNoShow]) after [noShowSeconds]. Mirrored by
/// `schema/tournament_match.schema.json`.
class TournamentMatchPayload {
  const TournamentMatchPayload({
    required this.matchId,
    required this.tournamentId,
    required this.round,
    required this.variant,
    required this.matchLength,
    required this.white,
    required this.black,
    this.noShowSeconds = 60,
  });

  final String matchId;
  final String tournamentId;
  final int round;
  final Variant variant;
  final int matchLength;
  final PlayerInfo white;
  final PlayerInfo black;
  final int noShowSeconds;

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'tournamentId': tournamentId,
    'round': round,
    'variant': variant.name,
    'matchLength': matchLength,
    'white': white.toJson(),
    'black': black.toJson(),
    'noShowSeconds': noShowSeconds,
  };

  static TournamentMatchPayload fromJson(Map<String, Object?> j) {
    final length = j.req<int>('matchLength');
    if (!QueueJoinPayload.lengths.contains(length)) {
      throw const ProtocolException('"matchLength" must be 1, 3, 5 or 7');
    }
    final round = j.req<int>('round');
    final noShow = j.req<int>('noShowSeconds');
    if (round < 1) throw const ProtocolException('"round" must be >= 1');
    if (noShow < 1 || noShow > 3600) {
      throw const ProtocolException('"noShowSeconds" must be 1..3600');
    }
    final white = PlayerInfo.fromJson(j.obj('white'));
    final black = PlayerInfo.fromJson(j.obj('black'));
    if (white.bot || black.bot || white.userId == black.userId) {
      throw const ProtocolException('Two different human players required');
    }
    return TournamentMatchPayload(
      matchId: j.str('matchId', max: 64),
      tournamentId: j.str('tournamentId', max: 64),
      round: round,
      variant: readEnum(Variant.values, j.str('variant'), 'variant'),
      matchLength: length,
      white: white,
      black: black,
      noShowSeconds: noShow,
    );
  }
}

/// `tournament.ready` (client → server): "Hazıram" for an assigned match.
class TournamentReadyPayload {
  const TournamentReadyPayload(this.matchId);

  final String matchId;

  Map<String, Object?> toJson() => {'matchId': matchId};

  static TournamentReadyPayload fromJson(Map<String, Object?> j) =>
      TournamentReadyPayload(j.str('matchId', max: 64));
}

/// `tournament.readyState` (server → client): an assigned match waiting
/// for its players (21.2 no-show countdown). Sent when the match is
/// assigned, when the player connects and whenever readiness changes.
class TournamentReadyStatePayload {
  const TournamentReadyStatePayload({
    required this.matchId,
    required this.tournamentId,
    required this.round,
    required this.you,
    required this.white,
    required this.black,
    required this.ready,
    required this.deadline,
  });

  final String matchId;
  final String tournamentId;
  final int round;

  /// The receiving player's side.
  final Side you;
  final PlayerInfo white;
  final PlayerInfo black;

  /// Which sides are present.
  final Map<Side, bool> ready;

  /// When an absent player loses by walkover (ms since epoch).
  final int deadline;

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'tournamentId': tournamentId,
    'round': round,
    'you': you.name,
    'white': white.toJson(),
    'black': black.toJson(),
    'ready': {for (final s in Side.values) s.name: ready[s] ?? false},
    'deadline': deadline,
  };

  static TournamentReadyStatePayload fromJson(Map<String, Object?> j) {
    final ready = j.obj('ready');
    return TournamentReadyStatePayload(
      matchId: j.str('matchId', max: 64),
      tournamentId: j.str('tournamentId', max: 64),
      round: j.req<int>('round'),
      you: readEnum(Side.values, j.str('you'), 'you'),
      white: PlayerInfo.fromJson(j.obj('white')),
      black: PlayerInfo.fromJson(j.obj('black')),
      ready: {for (final s in Side.values) s: ready[s.name] == true},
      deadline: j.req<int>('deadline'),
    );
  }
}

/// `tournament.walkover` (server → client): the assigned match was decided
/// without play (21.3). [winner] is null when neither player showed up.
class TournamentWalkoverPayload {
  const TournamentWalkoverPayload({
    required this.matchId,
    required this.tournamentId,
    this.winner,
  });

  final String matchId;
  final String tournamentId;
  final Side? winner;

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'tournamentId': tournamentId,
    if (winner != null) 'winner': winner!.name,
  };

  static TournamentWalkoverPayload fromJson(Map<String, Object?> j) =>
      TournamentWalkoverPayload(
        matchId: j.str('matchId', max: 64),
        tournamentId: j.str('tournamentId', max: 64),
        winner:
            j.opt<String>('winner') == null
                ? null
                : readEnum(Side.values, j.str('winner'), 'winner'),
      );
}

/// Game server → API, `POST /api/v1/internal/tournament-no-shows`: neither
/// player of an assigned match showed up (both lose the pairing). Mirrored
/// by `schema/tournament_no_show.schema.json`.
class TournamentNoShow {
  const TournamentNoShow({
    required this.matchId,
    required this.tournamentId,
    required this.endedAt,
  });

  final String matchId;
  final String tournamentId;
  final int endedAt;

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'tournamentId': tournamentId,
    'endedAt': endedAt,
  };

  static TournamentNoShow fromJson(Map<String, Object?> j) => TournamentNoShow(
    matchId: j.str('matchId', max: 64),
    tournamentId: j.str('tournamentId', max: 64),
    endedAt: j.req<int>('endedAt'),
  );
}
