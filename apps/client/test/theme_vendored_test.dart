import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `lib/theme/` must stay identical to the design skill (CLAUDE.md); never
/// run `dart format` on it.
void main() {
  test('lib/theme matches the nardarena-design skill byte for byte', () {
    final skill = Directory(
      '../../.claude/skills/nardarena-design/flutter/lib/theme',
    );
    final files = skill.listSync().whereType<File>().toList();
    expect(files, isNotEmpty);
    for (final f in files) {
      final name = f.uri.pathSegments.last;
      final ours = File('lib/theme/$name');
      expect(ours.readAsBytesSync(), f.readAsBytesSync(), reason: name);
    }
  });
}
