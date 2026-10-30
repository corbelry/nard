import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/app/app.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/data/database.dart';
import 'package:sqlite3/open.dart';

Future<AppDatabase> _db(
  WidgetTester tester, [
  Map<String, String>? settings,
]) async {
  final db = AppDatabase(NativeDatabase.memory());
  await tester.runAsync(() async {
    for (final e in (settings ?? const {}).entries) {
      await db.writeSetting(e.key, e.value);
    }
  });
  return db;
}

Future<void> _settle(WidgetTester tester) async {
  // Drift completes queries on real async gaps.
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  // Linux hosts ship libsqlite3.so.0 without the unversioned symlink.
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }

  testWidgets('first launch: splash → language → onboarding → home', (
    tester,
  ) async {
    final db = await _db(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const NardApp(),
      ),
    );
    await _settle(tester);
    expect(
      find.text('Choose language · Выберите язык · Dil seçin'),
      findsOneWidget,
    );
    await tester.tap(find.text('Azərbaycanca'));
    await _settle(tester);
    // Live preview: the title switches to Azerbaijani.
    expect(find.text('Dil seçin'), findsOneWidget);
    await tester.tap(find.text('Davam et'));
    await _settle(tester);
    expect(find.text('Hansı nərdi oynayırsan?'), findsOneWidget);
    await tester.tap(find.text('Davam et'));
    await _settle(tester);
    expect(find.text('Oyna'), findsOneWidget);
    expect(find.text('Kompüter'), findsOneWidget);
    final saved = await tester.runAsync(db.readSettings);
    expect(saved!['onboardingDone'], 'true');
    expect(saved['locale'], 'az');
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });

  testWidgets('returning player lands on home; setup → AI level', (
    tester,
  ) async {
    final db = await _db(tester, {'locale': 'en', 'onboardingDone': 'true'});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const NardApp(),
      ),
    );
    await _settle(tester);
    expect(find.text('Play'), findsOneWidget);
    await tester.tap(find.text('Computer'));
    await _settle(tester);
    expect(find.text('New game'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await _settle(tester);
    // Locked levels are shown but cannot be picked (ADR-019).
    expect(find.text('Coming soon'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
