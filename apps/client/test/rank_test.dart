import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/online/match_history.dart';
import 'package:nard_client/online/rank.dart';
import 'package:nard_core/nard_core.dart';

void main() {
  test('tiers follow the API floors', () {
    expect(tierOf(800), Tier.bronze);
    expect(tierOf(1299), Tier.bronze);
    expect(tierOf(1300), Tier.silver);
    expect(tierOf(1866), Tier.platinum);
    expect(tierOf(2300), Tier.grandmaster);
    expect(tierNamed('gold', 0), Tier.gold);
    expect(tierNamed(null, 1950), Tier.diamond);
  });

  test('sub-levels are thirds of the 200-point band, III lowest', () {
    expect(subLevel(1700), 3);
    expect(subLevel(1766), 3);
    expect(subLevel(1767), 2);
    expect(subLevel(1834), 1);
    expect(subLevel(1899), 1);
    // Bronze uses its top band; below it stays III.
    expect(subLevel(900), 3);
    expect(subLevel(1250), 1);
    expect(subLevel(2400), isNull);
  });

  test('next step names the next sub-level or tier', () {
    expect(nextStep(1700), (tier: Tier.platinum, sub: 2, points: 67));
    expect(nextStep(1866), (tier: Tier.diamond, sub: 3, points: 34));
    expect(nextStep(2250), (tier: Tier.grandmaster, sub: null, points: 50));
    expect(nextStep(2350), isNull);
    expect(bandProgress(1800), .5);
  });

  test('history rows are read from the player seat', () {
    final e = HistoryEntry.fromJson({
      'id': 7,
      'variant': 'longNard',
      'matchLength': 5,
      'mode': 'ranked',
      'white': {
        'name': 'Elvin',
        'bot': false,
        'ratingBefore': 1500,
        'ratingAfter': 1490,
      },
      'black': {
        'name': 'Nigar',
        'bot': false,
        'ratingBefore': 1520,
        'ratingAfter': 1530,
      },
      'winner': 'black',
      'whiteScore': 2,
      'blackScore': 5,
      'reason': 'completed',
      'endedAt': '2026-10-30T10:00:00+00:00',
      'you': 'black',
    });
    expect(e.variant, Variant.longNard);
    expect(e.opponentName, 'Elvin');
    expect(e.won, isTrue);
    expect((e.myScore, e.opponentScore), (5, 2));
    expect(e.ratingDelta, 10);
  });
}
