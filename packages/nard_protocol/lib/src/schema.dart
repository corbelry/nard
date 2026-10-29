/// JSON Schemas (draft 2020-12) for messages the PHP API consumes.
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
      'matchId': {'type': 'string', 'maxLength': 64},
      'variant': {
        'enum': ['shortNard', 'longNard'],
      },
      'matchLength': {
        'enum': [1, 3, 5, 7],
      },
      'mode': {
        'enum': ['casual', 'ranked'],
      },
      'white': _player,
      'black': _player,
      'winner': {
        'enum': ['white', 'black'],
      },
      'whiteScore': {'type': 'integer', 'minimum': 0},
      'blackScore': {'type': 'integer', 'minimum': 0},
      'reason': {
        'enum': ['completed', 'resigned', 'timeout', 'abandoned'],
      },
      'games': {
        'type': 'array',
        'items': {'type': 'object'},
      },
      'startedAt': {'type': 'integer'},
      'endedAt': {'type': 'integer'},
    },
  };

  static const all = {'match_result.schema.json': matchResult};
}
