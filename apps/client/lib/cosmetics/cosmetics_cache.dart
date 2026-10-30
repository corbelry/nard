import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'catalog.dart';

/// The last catalog and equipped slots, kept on disk so the equipped look
/// renders offline and before the API answers. Failures are ignored: the
/// built-in walnut set is always available.
class CosmeticsCache {
  Map<String, Object?>? _memory;

  Future<File?> _file() async {
    try {
      final dir = await getApplicationSupportDirectory();
      return File(p.join(dir.path, 'cosmetics_cache.json'));
    } on Object {
      return null;
    }
  }

  Future<Map<String, Object?>> _read() async {
    final memory = _memory;
    if (memory != null) return memory;
    var data = <String, Object?>{};
    try {
      final file = await _file();
      if (file != null && await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, Object?>) data = decoded;
      }
    } on Object {
      // Corrupt or unreadable: start empty.
    }
    return _memory = data;
  }

  Future<void> _write(String key, Object? value) async {
    final data = {...await _read(), key: value};
    _memory = data;
    try {
      final file = await _file();
      await file?.writeAsString(jsonEncode(data));
    } on Object {
      // Best effort.
    }
  }

  Future<Catalog?> catalog() async {
    final raw = (await _read())['catalog'];
    if (raw is! List) return null;
    final catalog = Catalog.fromJson(raw);
    return catalog.items.isEmpty ? null : catalog;
  }

  Future<void> saveCatalog(Catalog catalog) =>
      _write('catalog', catalog.toJson());

  Future<Map<String, String>> slots() async {
    final raw = (await _read())['slots'];
    return {
      if (raw is Map)
        for (final e in raw.entries)
          if (e.key is String && e.value is String)
            e.key as String: e.value as String,
    };
  }

  Future<void> saveSlots(Map<String, String> slots) => _write('slots', slots);
}

/// In-memory cache (tests).
class MemoryCosmeticsCache extends CosmeticsCache {
  MemoryCosmeticsCache([Map<String, Object?>? initial]) {
    _memory = initial ?? {};
  }

  @override
  Future<File?> _file() async => null;
}
