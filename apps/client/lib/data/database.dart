import 'package:drift/drift.dart';

part 'database.g.dart';

/// Key/value settings (see `AppSettings` for the typed view).
@DataClassName('SettingEntry')
class SettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// One finished offline game, kept for the replay viewer and local stats.
/// Offline games never affect rating (spec §8.10).
@DataClassName('GameRecordRow')
class GameRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Groups the games of one match.
  TextColumn get matchId => text()();
  IntColumn get gameIndex => integer()();

  /// `MatchSetup.toJson()`.
  TextColumn get setupJson => text()();

  /// `GameRecord.toJson()` from nard_core.
  TextColumn get recordJson => text()();
  TextColumn get variant => text()();
  TextColumn get opponent => text()();
  TextColumn get level => text().nullable()();
  TextColumn get winner => text()();
  TextColumn get winKind => text()();
  IntColumn get points => integer()();

  /// Match score after this game (White – Black).
  IntColumn get whiteScore => integer()();
  IntColumn get blackScore => integer()();
  BoolColumn get matchOver => boolean()();
  DateTimeColumn get playedAt => dateTime()();
}

@DriftDatabase(tables: [SettingEntries, GameRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<Map<String, String>> readSettings() async => {
    for (final row in await select(settingEntries).get()) row.key: row.value,
  };

  Future<void> writeSetting(String key, String value) => into(
    settingEntries,
  ).insertOnConflictUpdate(SettingEntry(key: key, value: value));

  Future<int> addGame(GameRecordsCompanion game) =>
      into(gameRecords).insert(game);

  /// Most recent games first.
  Future<List<GameRecordRow>> recentGames({int limit = 50}) =>
      (select(gameRecords)
            ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
            ..limit(limit))
          .get();

  Future<GameRecordRow?> gameById(int id) =>
      (select(gameRecords)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<GameRecordRow>> allGames() => select(gameRecords).get();
}
