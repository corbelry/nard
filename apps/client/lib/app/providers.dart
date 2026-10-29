import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/app_settings.dart';
import '../data/database.dart';

/// The local database; overridden in tests with an in-memory one.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(NativeDatabase.createInBackground(_DbFile.instance!));
  ref.onDispose(db.close);
  return db;
});

/// Resolves the database file before the app starts.
abstract final class _DbFile {
  static File? instance;
}

Future<void> initDatabaseFile() async {
  final dir = await getApplicationSupportDirectory();
  _DbFile.instance = File(p.join(dir.path, 'nard.sqlite'));
}

/// Persistent app settings.
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async =>
      AppSettings.fromMap(await ref.read(databaseProvider).readSettings());

  Future<void> save(AppSettings next) async {
    state = AsyncData(next);
    final db = ref.read(databaseProvider);
    for (final e in next.toMap().entries) {
      await db.writeSetting(e.key, e.value);
    }
  }

  Future<void> change(AppSettings Function(AppSettings) edit) async {
    final current = state.value ?? const AppSettings();
    await save(edit(current));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Settings with defaults while loading.
final currentSettingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(settingsProvider).value ?? const AppSettings(),
);
