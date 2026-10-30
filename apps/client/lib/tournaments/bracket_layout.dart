import 'dart:math';
import 'dart:ui';

import 'tournament_models.dart';
import 'tournament_text.dart' show knockoutStage;

/// One card of the knockout tree.
class BracketCell {
  const BracketCell({
    required this.round,
    required this.slot,
    required this.rect,
    this.match,
  });

  /// 1-based round and 0-based slot (`TournamentPairing.slot`).
  final int round;
  final int slot;
  final Rect rect;

  /// Null until the API has paired this round.
  final BracketMatch? match;

  Offset get leftMid => Offset(rect.left, rect.center.dy);
  Offset get rightMid => Offset(rect.right, rect.center.dy);
}

/// A connector from two feeders into the next round's card.
class BracketConnector {
  const BracketConnector({required this.points, required this.mine});

  /// Polyline points.
  final List<Offset> points;

  /// Part of my path (drawn in `accentHi`).
  final bool mine;
}

/// Geometry of 4.3 at scale 1 (tournaments.md §3): cards 150 × 61, column
/// pitch 186 from x 14, first-column cards at y 20 + i·120, later cards
/// centred on their two feeders; connectors go 20 right, join at x + 170
/// and enter the target after 16.
class BracketLayout {
  BracketLayout._(this.rounds, this.columns, this.connectors, this.size);

  static const double cardWidth = 150;
  static const double rowHeight = 30;
  static const double cardHeight = 2 * rowHeight + 1;
  static const double pitchX = 186;
  static const double firstX = 14;
  static const double firstY = 20;
  static const double pitchY = 120;

  /// Total rounds (1 = final only).
  final int rounds;

  /// Cells per round, in slot order.
  final List<List<BracketCell>> columns;
  final List<BracketConnector> connectors;
  final Size size;

  /// Stage keys per round: "1/16" … "final".
  List<String> get stages => [
    for (var r = 1; r <= rounds; r++) knockoutStage(rounds, r),
  ];

  static double cardX(int round) => firstX + (round - 1) * pitchX;

  /// Top of the card of [slot] in [round].
  static double cardY(int round, int slot) {
    final span = 1 << (round - 1);
    return firstY + pitchY * (slot * span + (span - 1) / 2);
  }

  /// Builds the full tree from [detail]; rounds the API has not paired yet
  /// are empty cards. [me] marks my path.
  factory BracketLayout.of(TournamentDetail detail, {String? me}) {
    final t = detail.tournament;
    final played = detail.rounds.length;
    final bySize = max(1, (log(max(2, t.size)) / ln2).ceil());
    final rounds = max(played, t.totalRounds ?? bySize);
    final byRound = {for (final r in detail.rounds) r.number: r};
    final columns = <List<BracketCell>>[];
    for (var r = 1; r <= rounds; r++) {
      final count = 1 << (rounds - r);
      final matches = {
        for (final m in byRound[r]?.matches ?? const <BracketMatch>[])
          m.slot: m,
      };
      columns.add([
        for (var s = 0; s < count; s++)
          BracketCell(
            round: r,
            slot: s,
            rect: Rect.fromLTWH(cardX(r), cardY(r, s), cardWidth, cardHeight),
            match: matches[s],
          ),
      ]);
    }
    final connectors = <BracketConnector>[];
    for (var r = 2; r <= rounds; r++) {
      for (final target in columns[r - 1]) {
        final a = columns[r - 2][2 * target.slot];
        final b = columns[r - 2][2 * target.slot + 1];
        final joinX = a.rect.right + 20;
        final mine =
            me != null &&
            (target.match?.involves(me) ?? false) &&
            ((a.match?.involves(me) ?? false) ||
                (b.match?.involves(me) ?? false));
        connectors.add(
          BracketConnector(
            mine: mine,
            points: [
              a.rightMid,
              Offset(joinX, a.rightMid.dy),
              Offset(joinX, b.rightMid.dy),
              b.rightMid,
            ],
          ),
        );
        connectors.add(
          BracketConnector(
            mine: mine,
            points: [Offset(joinX, target.leftMid.dy), target.leftMid],
          ),
        );
      }
    }
    final first = columns.first;
    final height = first.last.rect.bottom + firstY;
    final width = cardX(rounds) + cardWidth + firstX;
    return BracketLayout._(rounds, columns, connectors, Size(width, height));
  }

  /// My card: the next match if known, else the latest one with me.
  BracketCell? myCell(String? me, {String? nextMatchId}) {
    if (me == null) return null;
    BracketCell? found;
    for (final column in columns) {
      for (final cell in column) {
        final m = cell.match;
        if (m == null) continue;
        if (nextMatchId != null && m.matchId == nextMatchId) return cell;
        if (m.involves(me)) found = cell;
      }
    }
    return found;
  }
}
