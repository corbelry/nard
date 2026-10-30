import 'dart:math';

/// Rating tiers (API `Rating::TIERS`).
enum Tier { bronze, silver, gold, platinum, diamond, master, grandmaster }

/// Lowest rating of each tier, in [Tier] order.
const tierFloors = [0, 1300, 1500, 1700, 1900, 2100, 2300];

/// Width of a regular tier band.
const tierBand = 200;

Tier tierOf(int rating) {
  var tier = Tier.bronze;
  for (var i = 0; i < tierFloors.length; i++) {
    if (rating >= tierFloors[i]) tier = Tier.values[i];
  }
  return tier;
}

/// The API's tier name, or the tier of [rating] if unknown.
Tier tierNamed(String? name, int rating) {
  for (final t in Tier.values) {
    if (t.name == name) return t;
  }
  return tierOf(rating);
}

/// Start of the 200-point band used for sub-levels and progress. Bronze
/// (0–1299) uses its top band 1100–1299; grandmaster has none.
int _bandStart(Tier tier) =>
    tier == Tier.bronze ? tierFloors[1] - tierBand : tierFloors[tier.index];

/// Sub-level 3 (III, lowest) … 1 (I) by thirds of the band; null for
/// grandmaster (online.md §12.3 decision).
int? subLevel(int rating) {
  final tier = tierOf(rating);
  if (tier == Tier.grandmaster) return null;
  final pos = (rating - _bandStart(tier)).clamp(0, tierBand - 1);
  return 3 - pos * 3 ~/ tierBand;
}

/// Position inside the tier band, 0…1.
double bandProgress(int rating) {
  final tier = tierOf(rating);
  if (tier == Tier.grandmaster) return 1;
  return ((rating - _bandStart(tier)) / tierBand).clamp(0, 1).toDouble();
}

/// The next sub-level or tier above [rating] and the points still needed;
/// null at grandmaster.
({Tier tier, int? sub, int points})? nextStep(int rating) {
  final tier = tierOf(rating);
  if (tier == Tier.grandmaster) return null;
  final start = _bandStart(tier);
  final pos = max(0, rating - start);
  // Thresholds inside the band where the sub-level changes.
  for (final k in [1, 2]) {
    final threshold = (tierBand * k + 2) ~/ 3;
    if (pos < threshold) {
      return (tier: tier, sub: 3 - k, points: start + threshold - rating);
    }
  }
  final next = Tier.values[tier.index + 1];
  final floor = tierFloors[next.index];
  return (
    tier: next,
    sub: next == Tier.grandmaster ? null : 3,
    points: floor - rating,
  );
}

/// Roman numeral of a sub-level.
String subNumeral(int sub) => switch (sub) {
  1 => 'I',
  2 => 'II',
  _ => 'III',
};
