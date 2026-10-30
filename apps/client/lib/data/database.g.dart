// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingEntriesTable extends SettingEntries
    with TableInfo<$SettingEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingEntriesCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameRecordsTable extends GameRecords
    with TableInfo<$GameRecordsTable, GameRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIndexMeta = const VerificationMeta(
    'gameIndex',
  );
  @override
  late final GeneratedColumn<int> gameIndex = GeneratedColumn<int>(
    'game_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setupJsonMeta = const VerificationMeta(
    'setupJson',
  );
  @override
  late final GeneratedColumn<String> setupJson = GeneratedColumn<String>(
    'setup_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordJsonMeta = const VerificationMeta(
    'recordJson',
  );
  @override
  late final GeneratedColumn<String> recordJson = GeneratedColumn<String>(
    'record_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opponentMeta = const VerificationMeta(
    'opponent',
  );
  @override
  late final GeneratedColumn<String> opponent = GeneratedColumn<String>(
    'opponent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
    'winner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winKindMeta = const VerificationMeta(
    'winKind',
  );
  @override
  late final GeneratedColumn<String> winKind = GeneratedColumn<String>(
    'win_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whiteScoreMeta = const VerificationMeta(
    'whiteScore',
  );
  @override
  late final GeneratedColumn<int> whiteScore = GeneratedColumn<int>(
    'white_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blackScoreMeta = const VerificationMeta(
    'blackScore',
  );
  @override
  late final GeneratedColumn<int> blackScore = GeneratedColumn<int>(
    'black_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchOverMeta = const VerificationMeta(
    'matchOver',
  );
  @override
  late final GeneratedColumn<bool> matchOver = GeneratedColumn<bool>(
    'match_over',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("match_over" IN (0, 1))',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    matchId,
    gameIndex,
    setupJson,
    recordJson,
    variant,
    opponent,
    level,
    winner,
    winKind,
    points,
    whiteScore,
    blackScore,
    matchOver,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('game_index')) {
      context.handle(
        _gameIndexMeta,
        gameIndex.isAcceptableOrUnknown(data['game_index']!, _gameIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIndexMeta);
    }
    if (data.containsKey('setup_json')) {
      context.handle(
        _setupJsonMeta,
        setupJson.isAcceptableOrUnknown(data['setup_json']!, _setupJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_setupJsonMeta);
    }
    if (data.containsKey('record_json')) {
      context.handle(
        _recordJsonMeta,
        recordJson.isAcceptableOrUnknown(data['record_json']!, _recordJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_recordJsonMeta);
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    } else if (isInserting) {
      context.missing(_variantMeta);
    }
    if (data.containsKey('opponent')) {
      context.handle(
        _opponentMeta,
        opponent.isAcceptableOrUnknown(data['opponent']!, _opponentMeta),
      );
    } else if (isInserting) {
      context.missing(_opponentMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('winner')) {
      context.handle(
        _winnerMeta,
        winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta),
      );
    } else if (isInserting) {
      context.missing(_winnerMeta);
    }
    if (data.containsKey('win_kind')) {
      context.handle(
        _winKindMeta,
        winKind.isAcceptableOrUnknown(data['win_kind']!, _winKindMeta),
      );
    } else if (isInserting) {
      context.missing(_winKindMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('white_score')) {
      context.handle(
        _whiteScoreMeta,
        whiteScore.isAcceptableOrUnknown(data['white_score']!, _whiteScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_whiteScoreMeta);
    }
    if (data.containsKey('black_score')) {
      context.handle(
        _blackScoreMeta,
        blackScore.isAcceptableOrUnknown(data['black_score']!, _blackScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_blackScoreMeta);
    }
    if (data.containsKey('match_over')) {
      context.handle(
        _matchOverMeta,
        matchOver.isAcceptableOrUnknown(data['match_over']!, _matchOverMeta),
      );
    } else if (isInserting) {
      context.missing(_matchOverMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRecordRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      matchId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}match_id'],
          )!,
      gameIndex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}game_index'],
          )!,
      setupJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}setup_json'],
          )!,
      recordJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}record_json'],
          )!,
      variant:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}variant'],
          )!,
      opponent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}opponent'],
          )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      winner:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}winner'],
          )!,
      winKind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}win_kind'],
          )!,
      points:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}points'],
          )!,
      whiteScore:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}white_score'],
          )!,
      blackScore:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}black_score'],
          )!,
      matchOver:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}match_over'],
          )!,
      playedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}played_at'],
          )!,
    );
  }

  @override
  $GameRecordsTable createAlias(String alias) {
    return $GameRecordsTable(attachedDatabase, alias);
  }
}

class GameRecordRow extends DataClass implements Insertable<GameRecordRow> {
  final int id;

  /// Groups the games of one match.
  final String matchId;
  final int gameIndex;

  /// `MatchSetup.toJson()`.
  final String setupJson;

  /// `GameRecord.toJson()` from nard_core.
  final String recordJson;
  final String variant;
  final String opponent;
  final String? level;
  final String winner;
  final String winKind;
  final int points;

  /// Match score after this game (White – Black).
  final int whiteScore;
  final int blackScore;
  final bool matchOver;
  final DateTime playedAt;
  const GameRecordRow({
    required this.id,
    required this.matchId,
    required this.gameIndex,
    required this.setupJson,
    required this.recordJson,
    required this.variant,
    required this.opponent,
    this.level,
    required this.winner,
    required this.winKind,
    required this.points,
    required this.whiteScore,
    required this.blackScore,
    required this.matchOver,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<String>(matchId);
    map['game_index'] = Variable<int>(gameIndex);
    map['setup_json'] = Variable<String>(setupJson);
    map['record_json'] = Variable<String>(recordJson);
    map['variant'] = Variable<String>(variant);
    map['opponent'] = Variable<String>(opponent);
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    map['winner'] = Variable<String>(winner);
    map['win_kind'] = Variable<String>(winKind);
    map['points'] = Variable<int>(points);
    map['white_score'] = Variable<int>(whiteScore);
    map['black_score'] = Variable<int>(blackScore);
    map['match_over'] = Variable<bool>(matchOver);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  GameRecordsCompanion toCompanion(bool nullToAbsent) {
    return GameRecordsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      gameIndex: Value(gameIndex),
      setupJson: Value(setupJson),
      recordJson: Value(recordJson),
      variant: Value(variant),
      opponent: Value(opponent),
      level:
          level == null && nullToAbsent ? const Value.absent() : Value(level),
      winner: Value(winner),
      winKind: Value(winKind),
      points: Value(points),
      whiteScore: Value(whiteScore),
      blackScore: Value(blackScore),
      matchOver: Value(matchOver),
      playedAt: Value(playedAt),
    );
  }

  factory GameRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRecordRow(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      gameIndex: serializer.fromJson<int>(json['gameIndex']),
      setupJson: serializer.fromJson<String>(json['setupJson']),
      recordJson: serializer.fromJson<String>(json['recordJson']),
      variant: serializer.fromJson<String>(json['variant']),
      opponent: serializer.fromJson<String>(json['opponent']),
      level: serializer.fromJson<String?>(json['level']),
      winner: serializer.fromJson<String>(json['winner']),
      winKind: serializer.fromJson<String>(json['winKind']),
      points: serializer.fromJson<int>(json['points']),
      whiteScore: serializer.fromJson<int>(json['whiteScore']),
      blackScore: serializer.fromJson<int>(json['blackScore']),
      matchOver: serializer.fromJson<bool>(json['matchOver']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<String>(matchId),
      'gameIndex': serializer.toJson<int>(gameIndex),
      'setupJson': serializer.toJson<String>(setupJson),
      'recordJson': serializer.toJson<String>(recordJson),
      'variant': serializer.toJson<String>(variant),
      'opponent': serializer.toJson<String>(opponent),
      'level': serializer.toJson<String?>(level),
      'winner': serializer.toJson<String>(winner),
      'winKind': serializer.toJson<String>(winKind),
      'points': serializer.toJson<int>(points),
      'whiteScore': serializer.toJson<int>(whiteScore),
      'blackScore': serializer.toJson<int>(blackScore),
      'matchOver': serializer.toJson<bool>(matchOver),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  GameRecordRow copyWith({
    int? id,
    String? matchId,
    int? gameIndex,
    String? setupJson,
    String? recordJson,
    String? variant,
    String? opponent,
    Value<String?> level = const Value.absent(),
    String? winner,
    String? winKind,
    int? points,
    int? whiteScore,
    int? blackScore,
    bool? matchOver,
    DateTime? playedAt,
  }) => GameRecordRow(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    gameIndex: gameIndex ?? this.gameIndex,
    setupJson: setupJson ?? this.setupJson,
    recordJson: recordJson ?? this.recordJson,
    variant: variant ?? this.variant,
    opponent: opponent ?? this.opponent,
    level: level.present ? level.value : this.level,
    winner: winner ?? this.winner,
    winKind: winKind ?? this.winKind,
    points: points ?? this.points,
    whiteScore: whiteScore ?? this.whiteScore,
    blackScore: blackScore ?? this.blackScore,
    matchOver: matchOver ?? this.matchOver,
    playedAt: playedAt ?? this.playedAt,
  );
  GameRecordRow copyWithCompanion(GameRecordsCompanion data) {
    return GameRecordRow(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      gameIndex: data.gameIndex.present ? data.gameIndex.value : this.gameIndex,
      setupJson: data.setupJson.present ? data.setupJson.value : this.setupJson,
      recordJson:
          data.recordJson.present ? data.recordJson.value : this.recordJson,
      variant: data.variant.present ? data.variant.value : this.variant,
      opponent: data.opponent.present ? data.opponent.value : this.opponent,
      level: data.level.present ? data.level.value : this.level,
      winner: data.winner.present ? data.winner.value : this.winner,
      winKind: data.winKind.present ? data.winKind.value : this.winKind,
      points: data.points.present ? data.points.value : this.points,
      whiteScore:
          data.whiteScore.present ? data.whiteScore.value : this.whiteScore,
      blackScore:
          data.blackScore.present ? data.blackScore.value : this.blackScore,
      matchOver: data.matchOver.present ? data.matchOver.value : this.matchOver,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRecordRow(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('gameIndex: $gameIndex, ')
          ..write('setupJson: $setupJson, ')
          ..write('recordJson: $recordJson, ')
          ..write('variant: $variant, ')
          ..write('opponent: $opponent, ')
          ..write('level: $level, ')
          ..write('winner: $winner, ')
          ..write('winKind: $winKind, ')
          ..write('points: $points, ')
          ..write('whiteScore: $whiteScore, ')
          ..write('blackScore: $blackScore, ')
          ..write('matchOver: $matchOver, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    matchId,
    gameIndex,
    setupJson,
    recordJson,
    variant,
    opponent,
    level,
    winner,
    winKind,
    points,
    whiteScore,
    blackScore,
    matchOver,
    playedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRecordRow &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.gameIndex == this.gameIndex &&
          other.setupJson == this.setupJson &&
          other.recordJson == this.recordJson &&
          other.variant == this.variant &&
          other.opponent == this.opponent &&
          other.level == this.level &&
          other.winner == this.winner &&
          other.winKind == this.winKind &&
          other.points == this.points &&
          other.whiteScore == this.whiteScore &&
          other.blackScore == this.blackScore &&
          other.matchOver == this.matchOver &&
          other.playedAt == this.playedAt);
}

class GameRecordsCompanion extends UpdateCompanion<GameRecordRow> {
  final Value<int> id;
  final Value<String> matchId;
  final Value<int> gameIndex;
  final Value<String> setupJson;
  final Value<String> recordJson;
  final Value<String> variant;
  final Value<String> opponent;
  final Value<String?> level;
  final Value<String> winner;
  final Value<String> winKind;
  final Value<int> points;
  final Value<int> whiteScore;
  final Value<int> blackScore;
  final Value<bool> matchOver;
  final Value<DateTime> playedAt;
  const GameRecordsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.gameIndex = const Value.absent(),
    this.setupJson = const Value.absent(),
    this.recordJson = const Value.absent(),
    this.variant = const Value.absent(),
    this.opponent = const Value.absent(),
    this.level = const Value.absent(),
    this.winner = const Value.absent(),
    this.winKind = const Value.absent(),
    this.points = const Value.absent(),
    this.whiteScore = const Value.absent(),
    this.blackScore = const Value.absent(),
    this.matchOver = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  GameRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String matchId,
    required int gameIndex,
    required String setupJson,
    required String recordJson,
    required String variant,
    required String opponent,
    this.level = const Value.absent(),
    required String winner,
    required String winKind,
    required int points,
    required int whiteScore,
    required int blackScore,
    required bool matchOver,
    required DateTime playedAt,
  }) : matchId = Value(matchId),
       gameIndex = Value(gameIndex),
       setupJson = Value(setupJson),
       recordJson = Value(recordJson),
       variant = Value(variant),
       opponent = Value(opponent),
       winner = Value(winner),
       winKind = Value(winKind),
       points = Value(points),
       whiteScore = Value(whiteScore),
       blackScore = Value(blackScore),
       matchOver = Value(matchOver),
       playedAt = Value(playedAt);
  static Insertable<GameRecordRow> custom({
    Expression<int>? id,
    Expression<String>? matchId,
    Expression<int>? gameIndex,
    Expression<String>? setupJson,
    Expression<String>? recordJson,
    Expression<String>? variant,
    Expression<String>? opponent,
    Expression<String>? level,
    Expression<String>? winner,
    Expression<String>? winKind,
    Expression<int>? points,
    Expression<int>? whiteScore,
    Expression<int>? blackScore,
    Expression<bool>? matchOver,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (gameIndex != null) 'game_index': gameIndex,
      if (setupJson != null) 'setup_json': setupJson,
      if (recordJson != null) 'record_json': recordJson,
      if (variant != null) 'variant': variant,
      if (opponent != null) 'opponent': opponent,
      if (level != null) 'level': level,
      if (winner != null) 'winner': winner,
      if (winKind != null) 'win_kind': winKind,
      if (points != null) 'points': points,
      if (whiteScore != null) 'white_score': whiteScore,
      if (blackScore != null) 'black_score': blackScore,
      if (matchOver != null) 'match_over': matchOver,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  GameRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? matchId,
    Value<int>? gameIndex,
    Value<String>? setupJson,
    Value<String>? recordJson,
    Value<String>? variant,
    Value<String>? opponent,
    Value<String?>? level,
    Value<String>? winner,
    Value<String>? winKind,
    Value<int>? points,
    Value<int>? whiteScore,
    Value<int>? blackScore,
    Value<bool>? matchOver,
    Value<DateTime>? playedAt,
  }) {
    return GameRecordsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      gameIndex: gameIndex ?? this.gameIndex,
      setupJson: setupJson ?? this.setupJson,
      recordJson: recordJson ?? this.recordJson,
      variant: variant ?? this.variant,
      opponent: opponent ?? this.opponent,
      level: level ?? this.level,
      winner: winner ?? this.winner,
      winKind: winKind ?? this.winKind,
      points: points ?? this.points,
      whiteScore: whiteScore ?? this.whiteScore,
      blackScore: blackScore ?? this.blackScore,
      matchOver: matchOver ?? this.matchOver,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (gameIndex.present) {
      map['game_index'] = Variable<int>(gameIndex.value);
    }
    if (setupJson.present) {
      map['setup_json'] = Variable<String>(setupJson.value);
    }
    if (recordJson.present) {
      map['record_json'] = Variable<String>(recordJson.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (opponent.present) {
      map['opponent'] = Variable<String>(opponent.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (winKind.present) {
      map['win_kind'] = Variable<String>(winKind.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (whiteScore.present) {
      map['white_score'] = Variable<int>(whiteScore.value);
    }
    if (blackScore.present) {
      map['black_score'] = Variable<int>(blackScore.value);
    }
    if (matchOver.present) {
      map['match_over'] = Variable<bool>(matchOver.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameRecordsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('gameIndex: $gameIndex, ')
          ..write('setupJson: $setupJson, ')
          ..write('recordJson: $recordJson, ')
          ..write('variant: $variant, ')
          ..write('opponent: $opponent, ')
          ..write('level: $level, ')
          ..write('winner: $winner, ')
          ..write('winKind: $winKind, ')
          ..write('points: $points, ')
          ..write('whiteScore: $whiteScore, ')
          ..write('blackScore: $blackScore, ')
          ..write('matchOver: $matchOver, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  late final $GameRecordsTable gameRecords = $GameRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settingEntries,
    gameRecords,
  ];
}

typedef $$SettingEntriesTableCreateCompanionBuilder =
    SettingEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingEntriesTableUpdateCompanionBuilder =
    SettingEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingEntriesTable,
          SettingEntry,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(
    _$AppDatabase db,
    $SettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingEntriesTable,
      SettingEntry,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$GameRecordsTableCreateCompanionBuilder =
    GameRecordsCompanion Function({
      Value<int> id,
      required String matchId,
      required int gameIndex,
      required String setupJson,
      required String recordJson,
      required String variant,
      required String opponent,
      Value<String?> level,
      required String winner,
      required String winKind,
      required int points,
      required int whiteScore,
      required int blackScore,
      required bool matchOver,
      required DateTime playedAt,
    });
typedef $$GameRecordsTableUpdateCompanionBuilder =
    GameRecordsCompanion Function({
      Value<int> id,
      Value<String> matchId,
      Value<int> gameIndex,
      Value<String> setupJson,
      Value<String> recordJson,
      Value<String> variant,
      Value<String> opponent,
      Value<String?> level,
      Value<String> winner,
      Value<String> winKind,
      Value<int> points,
      Value<int> whiteScore,
      Value<int> blackScore,
      Value<bool> matchOver,
      Value<DateTime> playedAt,
    });

class $$GameRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $GameRecordsTable> {
  $$GameRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gameIndex => $composableBuilder(
    column: $table.gameIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setupJson => $composableBuilder(
    column: $table.setupJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponent => $composableBuilder(
    column: $table.opponent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winKind => $composableBuilder(
    column: $table.winKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get whiteScore => $composableBuilder(
    column: $table.whiteScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blackScore => $composableBuilder(
    column: $table.blackScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get matchOver => $composableBuilder(
    column: $table.matchOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameRecordsTable> {
  $$GameRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchId => $composableBuilder(
    column: $table.matchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gameIndex => $composableBuilder(
    column: $table.gameIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setupJson => $composableBuilder(
    column: $table.setupJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponent => $composableBuilder(
    column: $table.opponent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winner => $composableBuilder(
    column: $table.winner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winKind => $composableBuilder(
    column: $table.winKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get whiteScore => $composableBuilder(
    column: $table.whiteScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blackScore => $composableBuilder(
    column: $table.blackScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get matchOver => $composableBuilder(
    column: $table.matchOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameRecordsTable> {
  $$GameRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<int> get gameIndex =>
      $composableBuilder(column: $table.gameIndex, builder: (column) => column);

  GeneratedColumn<String> get setupJson =>
      $composableBuilder(column: $table.setupJson, builder: (column) => column);

  GeneratedColumn<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get opponent =>
      $composableBuilder(column: $table.opponent, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<String> get winKind =>
      $composableBuilder(column: $table.winKind, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get whiteScore => $composableBuilder(
    column: $table.whiteScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get blackScore => $composableBuilder(
    column: $table.blackScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get matchOver =>
      $composableBuilder(column: $table.matchOver, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$GameRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameRecordsTable,
          GameRecordRow,
          $$GameRecordsTableFilterComposer,
          $$GameRecordsTableOrderingComposer,
          $$GameRecordsTableAnnotationComposer,
          $$GameRecordsTableCreateCompanionBuilder,
          $$GameRecordsTableUpdateCompanionBuilder,
          (
            GameRecordRow,
            BaseReferences<_$AppDatabase, $GameRecordsTable, GameRecordRow>,
          ),
          GameRecordRow,
          PrefetchHooks Function()
        > {
  $$GameRecordsTableTableManager(_$AppDatabase db, $GameRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GameRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GameRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$GameRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<int> gameIndex = const Value.absent(),
                Value<String> setupJson = const Value.absent(),
                Value<String> recordJson = const Value.absent(),
                Value<String> variant = const Value.absent(),
                Value<String> opponent = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> winner = const Value.absent(),
                Value<String> winKind = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> whiteScore = const Value.absent(),
                Value<int> blackScore = const Value.absent(),
                Value<bool> matchOver = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => GameRecordsCompanion(
                id: id,
                matchId: matchId,
                gameIndex: gameIndex,
                setupJson: setupJson,
                recordJson: recordJson,
                variant: variant,
                opponent: opponent,
                level: level,
                winner: winner,
                winKind: winKind,
                points: points,
                whiteScore: whiteScore,
                blackScore: blackScore,
                matchOver: matchOver,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String matchId,
                required int gameIndex,
                required String setupJson,
                required String recordJson,
                required String variant,
                required String opponent,
                Value<String?> level = const Value.absent(),
                required String winner,
                required String winKind,
                required int points,
                required int whiteScore,
                required int blackScore,
                required bool matchOver,
                required DateTime playedAt,
              }) => GameRecordsCompanion.insert(
                id: id,
                matchId: matchId,
                gameIndex: gameIndex,
                setupJson: setupJson,
                recordJson: recordJson,
                variant: variant,
                opponent: opponent,
                level: level,
                winner: winner,
                winKind: winKind,
                points: points,
                whiteScore: whiteScore,
                blackScore: blackScore,
                matchOver: matchOver,
                playedAt: playedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameRecordsTable,
      GameRecordRow,
      $$GameRecordsTableFilterComposer,
      $$GameRecordsTableOrderingComposer,
      $$GameRecordsTableAnnotationComposer,
      $$GameRecordsTableCreateCompanionBuilder,
      $$GameRecordsTableUpdateCompanionBuilder,
      (
        GameRecordRow,
        BaseReferences<_$AppDatabase, $GameRecordsTable, GameRecordRow>,
      ),
      GameRecordRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingEntriesTableTableManager get settingEntries =>
      $$SettingEntriesTableTableManager(_db, _db.settingEntries);
  $$GameRecordsTableTableManager get gameRecords =>
      $$GameRecordsTableTableManager(_db, _db.gameRecords);
}
