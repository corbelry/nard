// Fails when line coverage in coverage/lcov.info is below the threshold.
// Usage: dart run tool/check_coverage.dart [minPercent]
import 'dart:io';

void main(List<String> args) {
  final min = args.isEmpty ? 95.0 : double.parse(args.first);
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln(
      'coverage/lcov.info not found; run test_with_coverage first',
    );
    exit(2);
  }
  var found = 0;
  var hit = 0;
  String? current;
  final perFile = <String, (int, int)>{};
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) current = line.substring(3);
    if (line.startsWith('LF:')) found += int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
    if (line.startsWith('DA:') && current != null) {
      final count = int.parse(line.substring(3).split(',')[1]);
      final (f, h) = perFile[current] ?? (0, 0);
      perFile[current] = (f + 1, h + (count > 0 ? 1 : 0));
    }
  }
  for (final e in perFile.entries) {
    final pct = 100 * e.value.$2 / e.value.$1;
    stdout.writeln('${pct.toStringAsFixed(1).padLeft(6)}%  ${e.key}');
  }
  final total = found == 0 ? 0 : 100 * hit / found;
  stdout.writeln(
    'Total line coverage: ${total.toStringAsFixed(2)}% ($hit/$found)',
  );
  if (total < min) {
    stderr.writeln('Coverage below $min%');
    exit(1);
  }
}
