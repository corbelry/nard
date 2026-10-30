import '../store/store_models.dart';

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// Login streak (12.2): current day of the 7-day cycle and its rewards.
class Streak {
  const Streak({
    this.current = 0,
    this.best = 0,
    this.lastCheckin,
    this.rewards = const [],
  });

  final int current;
  final int best;
  final String? lastCheckin;

  /// Coins for days 1..7.
  final List<int> rewards;

  /// 1..7 within the cycle for streak day [n] (1-based).
  static int cycleDay(int n) => n <= 0 ? 1 : (n - 1) % 7 + 1;

  int rewardFor(int day) =>
      rewards.isEmpty ? 0 : rewards[(cycleDay(day) - 1) % rewards.length];

  static Streak fromJson(Object? j) {
    if (j is! Map) return const Streak();
    return Streak(
      current: _int(j['current']),
      best: _int(j['best']),
      lastCheckin: j['lastCheckin'] as String?,
      rewards: [for (final r in (j['rewards'] as List?) ?? const []) _int(r)],
    );
  }
}

enum MissionKind { daily, weekly }

enum MissionState { inProgress, claimable, claimed }

/// A daily or weekly mission (12.1).
class Mission {
  const Mission({
    required this.id,
    required this.kind,
    required this.event,
    required this.target,
    this.progress = 0,
    this.coins = 0,
    this.xp = 0,
    this.completed = false,
    this.claimed = false,
  });

  final String id;
  final MissionKind kind;

  /// Counter it follows: `doubles`, `ranked_win`, `cube_take_win`,
  /// `long_play`, `mars`, `play`, `win` …
  final String event;
  final int target;
  final int progress;
  final int coins;
  final int xp;
  final bool completed;
  final bool claimed;

  MissionState get state =>
      claimed
          ? MissionState.claimed
          : completed
          ? MissionState.claimable
          : MissionState.inProgress;

  double get fraction =>
      target <= 0 ? 0 : (progress / target).clamp(0, 1).toDouble();

  static Mission fromJson(Map<String, Object?> j) => Mission(
    id: j['id'] as String? ?? '',
    kind: j['kind'] == 'weekly' ? MissionKind.weekly : MissionKind.daily,
    event: j['event'] as String? ?? '',
    target: _int(j['target']),
    progress: _int(j['progress']),
    coins: _int(j['coins']),
    xp: _int(j['xp']),
    completed: j['completed'] == true,
    claimed: j['claimed'] == true,
  );
}

/// `GET /me/progress`.
class Progress {
  const Progress({
    this.level = 1,
    this.xp = 0,
    this.xpForNext = 1,
    this.streak = const Streak(),
    this.missions = const [],
    this.achievements = const [],
    this.title,
    this.dailyBonus = 0,
    this.resetsDaily,
    this.resetsWeekly,
  });

  final int level;

  /// XP within the current level.
  final int xp;
  final int xpForNext;
  final Streak streak;
  final List<Mission> missions;

  /// Unlocked achievement ids.
  final List<String> achievements;

  /// Selected title item id.
  final String? title;

  /// Coins for finishing every daily mission.
  final int dailyBonus;
  final DateTime? resetsDaily;
  final DateTime? resetsWeekly;

  double get levelFraction =>
      xpForNext <= 0 ? 0 : (xp / xpForNext).clamp(0, 1).toDouble();

  List<Mission> of(MissionKind kind) =>
      missions.where((m) => m.kind == kind).toList();

  Progress copyWith({String? title, bool clearTitle = false}) => Progress(
    level: level,
    xp: xp,
    xpForNext: xpForNext,
    streak: streak,
    missions: missions,
    achievements: achievements,
    title: clearTitle ? null : (title ?? this.title),
    dailyBonus: dailyBonus,
    resetsDaily: resetsDaily,
    resetsWeekly: resetsWeekly,
  );

  static Progress fromJson(Map<String, Object?> json) {
    final j =
        json['progress'] is Map<String, Object?>
            ? json['progress']! as Map<String, Object?>
            : json;
    final resets = j['resetsAt'];
    return Progress(
      level: _int(j['level']).clamp(1, 1 << 30),
      xp: _int(j['xp']),
      xpForNext: _int(j['xpForNext']),
      streak: Streak.fromJson(j['streak']),
      missions: [
        for (final m in (j['missions'] as List?) ?? const [])
          if (m is Map<String, Object?>) Mission.fromJson(m),
      ],
      achievements: [
        for (final a in (j['achievements'] as List?) ?? const [])
          if (a is String) a,
      ],
      title: j['title'] as String?,
      dailyBonus: _int(j['dailyBonus']),
      resetsDaily: resets is Map ? _date(resets['daily']) : null,
      resetsWeekly: resets is Map ? _date(resets['weekly']) : null,
    );
  }
}

/// `POST /me/checkin`: coins credited today (0 when already checked in).
class CheckIn {
  const CheckIn({required this.coins, required this.streak, this.wallet});

  final int coins;
  final int streak;
  final Wallet? wallet;

  static CheckIn fromJson(Map<String, Object?> j) => CheckIn(
    coins: _int(j['coins']),
    streak: _int(j['streak']),
    wallet: j['wallet'] == null ? null : Wallet.fromJson(j['wallet']),
  );
}

/// `POST /me/missions/{id}/claim`.
class ClaimResult {
  const ClaimResult({required this.progress, required this.wallet});

  final Progress progress;
  final Wallet wallet;

  static ClaimResult fromJson(Map<String, Object?> j) => ClaimResult(
    progress: Progress.fromJson(
      (j['progress'] as Map<String, Object?>?) ?? const {},
    ),
    wallet: Wallet.fromJson(j['wallet']),
  );
}
