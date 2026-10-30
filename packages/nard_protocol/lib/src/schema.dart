/// JSON Schemas (draft 2020-12) for messages exchanged with the PHP API.
/// Exported to `schema/` by `dart run tool/export_schema.dart`.
abstract final class Schemas {
  static const _player = {
    'type': 'object',
    'required': ['userId', 'name', 'bot'],
    'properties': {
      'userId': {'type': 'string', 'maxLength': 64},
      'name': {'type': 'string', 'maxLength': 64},
      'rating': {'type': 'integer'},
      'country': {'type': 'string', 'minLength': 2, 'maxLength': 2},
      'bot': {'type': 'boolean'},
    },
  };

  static const _variant = {
    'enum': ['shortNard', 'longNard'],
  };

  static const _length = {
    'enum': [1, 3, 5, 7],
  };

  static const _id = {'type': 'string', 'maxLength': 64};

  /// Game server → API: a finished match.
  static const matchResult = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'https://nardarena.app/schema/match_result.json',
    'title': 'MatchResult',
    'type': 'object',
    'required': [
      'matchId',
      'variant',
      'matchLength',
      'mode',
      'white',
      'black',
      'winner',
      'whiteScore',
      'blackScore',
      'reason',
      'games',
      'startedAt',
      'endedAt',
    ],
    'properties': {
      'matchId': _id,
      'variant': _variant,
      'matchLength': _length,
      'mode': {
        'enum': ['casual', 'ranked', 'tournament'],
      },
      'white': _player,
      'black': _player,
      'winner': {
        'enum': ['white', 'black'],
      },
      'whiteScore': {'type': 'integer', 'minimum': 0},
      'blackScore': {'type': 'integer', 'minimum': 0},
      'reason': {
        'enum': ['completed', 'resigned', 'timeout', 'abandoned', 'walkover'],
      },
      'games': {
        'type': 'array',
        'items': {'type': 'object'},
      },
      'startedAt': {'type': 'integer'},
      'endedAt': {'type': 'integer'},
      // Required when mode is `tournament`.
      'tournamentId': _id,
      // Optional (ADR-044); absent from older game servers.
      'timeControl': {
        'enum': ['blitz', 'rapid', 'classic'],
      },
    },
  };

  /// API → game server: a tournament pairing to play.
  static const tournamentMatch = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'https://nardarena.app/schema/tournament_match.json',
    'title': 'TournamentMatch',
    'type': 'object',
    'required': [
      'matchId',
      'tournamentId',
      'round',
      'variant',
      'matchLength',
      'white',
      'black',
      'noShowSeconds',
    ],
    'properties': {
      'matchId': _id,
      'tournamentId': _id,
      'round': {'type': 'integer', 'minimum': 1},
      'variant': _variant,
      'matchLength': _length,
      'white': _player,
      'black': _player,
      'noShowSeconds': {'type': 'integer', 'minimum': 1, 'maximum': 3600},
    },
  };

  /// Game server → API: neither player of a tournament match showed up.
  static const tournamentNoShow = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'https://nardarena.app/schema/tournament_no_show.json',
    'title': 'TournamentNoShow',
    'type': 'object',
    'required': ['matchId', 'tournamentId', 'endedAt'],
    'properties': {
      'matchId': _id,
      'tournamentId': _id,
      'endedAt': {'type': 'integer'},
    },
  };

  /// API → game server: a player's moderation state for live sessions.
  static const moderation = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'https://nardarena.app/schema/moderation.json',
    'title': 'Moderation',
    'type': 'object',
    'required': ['userId', 'banned', 'muted'],
    'properties': {
      'userId': _id,
      'banned': {'type': 'boolean'},
      'muted': {'type': 'boolean'},
      // Epoch seconds; null or absent = no matchmaking cooldown.
      'queueCooldownUntil': {
        'type': ['integer', 'null'],
      },
    },
  };

  /// API → game server: inbox rows for players' open sockets (ADR-049).
  static const notify = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'https://nardarena.app/schema/notify.json',
    'title': 'Notify',
    'type': 'object',
    'required': ['notifications'],
    'properties': {
      'notifications': {
        'type': 'array',
        'maxItems': 500,
        'items': {
          'type': 'object',
          'required': ['userId', 'notification'],
          'properties': {
            'userId': _id,
            // The API's Notification object (docs/api/notifications.md).
            'notification': {
              'type': 'object',
              'required': ['id', 'type'],
              'properties': {
                'id': {'type': 'integer'},
                'type': {'type': 'string', 'minLength': 1, 'maxLength': 64},
              },
            },
          },
        },
      },
    },
  };

  /// API → game server: a tournament changed; tell its connected entrants.
  static const tournamentUpdated = {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'https://nardarena.app/schema/tournament_updated.json',
    'title': 'TournamentUpdated',
    'type': 'object',
    'required': ['tournamentId', 'userIds'],
    'properties': {
      'tournamentId': _id,
      'userIds': {'type': 'array', 'maxItems': 1000, 'items': _id},
    },
  };

  static const all = {
    'match_result.schema.json': matchResult,
    'moderation.schema.json': moderation,
    'notify.schema.json': notify,
    'tournament_updated.schema.json': tournamentUpdated,
    'tournament_match.schema.json': tournamentMatch,
    'tournament_no_show.schema.json': tournamentNoShow,
  };
}
