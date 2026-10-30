// Fair-play move quality (spec §8.14, ADR-042): reads match records as JSON
// lines on stdin and writes one JSON line per player with the agreement
// with HeuristicBot(BotLevel.hard) and the average evaluation loss.
//
// Input lines (from `php artisan anticheat:export`):
//   {"matchId": "…", "white": {"userId": "1"}, "black": {"userId": "2"},
//    "games": [{"record": {…GameRecord…}, …}]}
// Output lines (imported by `php artisan anticheat:scan --engine=<file>`):
//   {"userId": "1", "matches": 12, "games": 30, "decisions": 410,
//    "agreement": 0.6312, "avgLoss": 0.01234}
//
// Usage (from packages/nard_ai):
//   dart run tool/move_quality.dart < matches.jsonl > quality.jsonl
// or compile once: dart compile exe tool/move_quality.dart -o move_quality
import 'dart:convert';
import 'dart:io';

import 'package:nard_ai/nard_ai.dart';

Future<void> main() async {
  final analyzer = MoveQualityAnalyzer();
  var lines = 0;
  var bad = 0;
  await for (final line in stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.trim().isEmpty) continue;
    lines++;
    try {
      final json = jsonDecode(line);
      if (json is Map<String, Object?>) {
        analyzer.addMatch(json);
      } else {
        bad++;
      }
    } on FormatException {
      bad++;
    }
  }
  for (final player in analyzer.players) {
    stdout.writeln(jsonEncode(player.toJson()));
  }
  stderr.writeln(
    'move_quality: $lines match(es), $bad bad line(s), '
    '${analyzer.skippedGames} skipped game(s), '
    '${analyzer.players.length} player(s)',
  );
}
