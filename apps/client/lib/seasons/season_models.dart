import 'package:nard_core/nard_core.dart' show Variant;

import '../tournaments/tournament_models.dart' show UserLite, variantFromApi;

/// Season, pass, summary and leaderboard shapes of `docs/api/seasons.md`.

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

int? _intOrNull(Object? v) => v is num ? v.toInt() : null;

class Season {
  const Season({
    required this.id,
    required this.number,
    required this.names,
    this.active = true,
    this.startsAt,
    this.endsAt,
    this.secondsLeft = 0,
  });

  final String id;
  final int number;
  final Map<String, String> names;
  final bool active;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int secondsLeft;

  String nameFor(String locale) =>
      names[locale] ?? names['en'] ?? (names.isEmpty ? '' : names.values.first);

  static Season fromJson(Map<String, Object?> j) {
    final name = j['name'];
    return Season(
      id: '${j['id']}',
      number: _int(j['number'], 1),
      names:
          name is Map
              ? {
                for (final e in name.entries)
                  if (e.value is String) '${e.key}': e.value as String,
              }
              : const {},
      active: j['status'] != 'finished',
      startsAt: DateTime.tryParse('${j['startsAt']}')?.toLocal(),
      endsAt: DateTime.tryParse('${j['endsAt']}')?.toLocal(),
      secondsLeft: _int(j['secondsLeft']),
    );
  }
}

enum PassTrack { free, premium }

enum RewardKind { coins, gems, item }

class PassReward {
  const PassReward({
    required this.level,
    required this.track,
    required this.kind,
    this.amount,
    this.itemId,
    this.claimed = false,
    this.claimable = false,
  });

  final int level;
  final PassTrack track;
  final RewardKind kind;
  final int? amount;
  final String? itemId;
  final bool claimed;
  final bool claimable;

  static PassReward fromJson(Map<String, Object?> j) => PassReward(
    level: _int(j['level'], 1),
    track: j['track'] == 'premium' ? PassTrack.premium : PassTrack.free,
    kind: switch (j['kind']) {
      'gems' => RewardKind.gems,
      'item' => RewardKind.item,
      _ => RewardKind.coins,
    },
    amount: _intOrNull(j['amount']),
    itemId: j['itemId'] as String?,
    claimed: j['claimed'] == true,
    claimable: j['claimable'] == true,
  );
}

class EndReward {
  const EndReward({
    required this.tier,
    required this.minRating,
    required this.coins,
    this.itemId,
  });

  final String tier;
  final int minRating;
  final int coins;
  final String? itemId;

  static EndReward fromJson(Map<String, Object?> j) => EndReward(
    tier: j['tier'] as String? ?? 'bronze',
    minRating: _int(j['minRating']),
    coins: _int(j['coins']),
    itemId: j['itemId'] as String?,
  );
}

/// `GET /season`: the running season and my pass.
class SeasonView {
  const SeasonView({
    required this.season,
    this.levels = 50,
    this.xpPerLevel = 1000,
    this.xp = 0,
    this.level = 0,
    this.levelXp = 0,
    this.premium = false,
    this.premiumGems = 950,
    this.rewards = const [],
    this.endRewards = const [],
    this.currentTier,
    this.targetTier,
    this.targetPoints,
  });

  final Season season;
  final int levels;
  final int xpPerLevel;
  final int xp;
  final int level;

  /// XP inside the current level.
  final int levelXp;
  final bool premium;
  final int premiumGems;
  final List<PassReward> rewards;
  final List<EndReward> endRewards;
  final String? currentTier;
  final String? targetTier;
  final int? targetPoints;

  PassReward? reward(int level, PassTrack track) {
    for (final r in rewards) {
      if (r.level == level && r.track == track) return r;
    }
    return null;
  }

  int get claimableCount => rewards.where((r) => r.claimable).length;

  EndReward? endRewardFor(String? tier) {
    for (final r in endRewards) {
      if (r.tier == tier) return r;
    }
    return null;
  }

  static SeasonView fromJson(Map<String, Object?> j) {
    final pass = j['pass'] as Map<String, Object?>? ?? const {};
    final target = j['myTarget'];
    final price = pass['premiumPrice'];
    return SeasonView(
      season: Season.fromJson(j['season']! as Map<String, Object?>),
      levels: _int(pass['levels'], 50),
      xpPerLevel: _int(pass['xpPerLevel'], 1000),
      xp: _int(pass['xp']),
      level: _int(pass['level']),
      levelXp: _int(pass['levelXp']),
      premium: pass['premium'] == true,
      premiumGems: price is Map ? _int(price['gems'], 950) : 950,
      rewards: [
        for (final r in (pass['rewards'] as List?) ?? const [])
          if (r is Map<String, Object?>) PassReward.fromJson(r),
      ],
      endRewards: [
        for (final r in (j['endRewards'] as List?) ?? const [])
          if (r is Map<String, Object?>) EndReward.fromJson(r),
      ],
      currentTier: j['currentTier'] as String?,
      targetTier: target is Map ? target['tier'] as String? : null,
      targetPoints: target is Map ? _intOrNull(target['pointsLeft']) : null,
    );
  }
}

/// One variant row of `GET /season/summary`.
class SeasonResult {
  const SeasonResult({
    required this.variant,
    required this.tier,
    required this.rating,
    this.rank,
    this.countryRank,
    this.ratingDelta = 0,
    this.matches = 0,
    this.wins = 0,
    this.winRate = 0,
  });

  final Variant variant;
  final String tier;
  final int rating;
  final int? rank;
  final int? countryRank;
  final int ratingDelta;
  final int matches;
  final int wins;

  /// Percent 0..100.
  final int winRate;

  static SeasonResult fromJson(Map<String, Object?> j) {
    return SeasonResult(
      variant: variantFromApi(j['variant']),
      tier: j['tier'] as String? ?? 'bronze',
      rating: _int(j['rating'], 1500),
      rank: _intOrNull(j['rank']),
      countryRank: _intOrNull(j['countryRank']),
      ratingDelta: _int(j['ratingDelta']),
      matches: _int(j['matches']),
      wins: _int(j['wins']),
      winRate: _int(j['winRate']),
    );
  }
}

class SeasonSummary {
  const SeasonSummary({
    required this.season,
    this.results = const [],
    this.rewardTier,
    this.rewardCoins = 0,
    this.rewardItem,
    this.ratings = const {},
  });

  final Season season;
  final List<SeasonResult> results;

  /// Live ratings per variant after the soft reset.
  final Map<String, int> ratings;
  final String? rewardTier;
  final int rewardCoins;
  final String? rewardItem;

  /// The variant with the most matches (the season tier shown on 7.2).
  SeasonResult? get main {
    if (results.isEmpty) return null;
    return results.reduce((a, b) => b.matches > a.matches ? b : a);
  }

  static SeasonSummary fromJson(Map<String, Object?> j) {
    final reward = j['reward'];
    final ratings = j['ratings'];
    return SeasonSummary(
      ratings:
          ratings is Map
              ? {
                for (final e in ratings.entries)
                  if (e.value is num) '${e.key}': (e.value as num).toInt(),
              }
              : const {},
      season: Season.fromJson(j['season']! as Map<String, Object?>),
      results: [
        for (final r in (j['results'] as List?) ?? const [])
          if (r is Map<String, Object?>) SeasonResult.fromJson(r),
      ],
      rewardTier: reward is Map ? reward['tier'] as String? : null,
      rewardCoins: reward is Map ? _int(reward['coins']) : 0,
      rewardItem: reward is Map ? reward['itemId'] as String? : null,
    );
  }
}

enum LeaderboardScope { global, country, friends, clan }

class LeaderboardRow {
  const LeaderboardRow({
    required this.rank,
    required this.user,
    required this.rating,
    this.tier,
  });

  final int rank;
  final UserLite user;
  final int rating;
  final String? tier;

  static LeaderboardRow fromJson(Map<String, Object?> j) => LeaderboardRow(
    rank: _int(j['rank'], 1),
    user: UserLite.fromJson(j['user']! as Map<String, Object?>),
    rating: _int(j['rating'], 1500),
    tier: j['tier'] as String?,
  );
}

class Leaderboard {
  const Leaderboard({
    this.entries = const [],
    this.minMatches = 5,
    this.myRank,
    this.myRating,
    this.me,
    this.season,
  });

  final List<LeaderboardRow> entries;
  final int minMatches;
  final int? myRank;
  final int? myRating;
  final UserLite? me;
  final int? season;

  static Leaderboard fromJson(Map<String, Object?> j) {
    final me = j['me'];
    return Leaderboard(
      entries: [
        for (final e in (j['entries'] as List?) ?? const [])
          if (e is Map<String, Object?>) LeaderboardRow.fromJson(e),
      ],
      minMatches: _int(j['minMatches'], 5),
      myRank: me is Map ? _intOrNull(me['rank']) : null,
      myRating: me is Map ? _intOrNull(me['rating']) : null,
      me: me is Map ? UserLite.maybe(me['user']) : null,
      season: _intOrNull(j['season']),
    );
  }
}
