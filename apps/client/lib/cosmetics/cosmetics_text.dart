import '../l10n/gen/app_localizations.dart';
import '../progression/progress_models.dart';
import 'catalog.dart';

/// "12 450": thousands grouped with a space (store.md §7.1).
String formatAmount(int value) {
  final digits = value.abs().toString();
  final out = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(' ');
    out.write(digits[i]);
  }
  return out.toString();
}

/// "06:12:40" (hours may exceed 24).
String formatCountdown(Duration d) {
  final s = d.isNegative ? 0 : d.inSeconds;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(s ~/ 3600)}:${two(s % 3600 ~/ 60)}:${two(s % 60)}';
}

String categoryName(AppLocalizations l, String category) => switch (category) {
  ItemCategory.board => l.categoryBoard,
  ItemCategory.checkers => l.categoryCheckers,
  ItemCategory.dice => l.categoryDice,
  ItemCategory.diceCup => l.categoryDiceCup,
  ItemCategory.cube => l.categoryCube,
  ItemCategory.table => l.categoryBackground,
  ItemCategory.sounds => l.categorySounds,
  ItemCategory.emotes => l.categoryEmote,
  ItemCategory.avatarFrame => l.categoryAvatarFrame,
  ItemCategory.title => l.categoryTitle,
  ItemCategory.winEffect => l.categoryWinEffect,
  _ => l.categoryOther,
};

String rarityName(AppLocalizations l, String rarity) => switch (rarity) {
  'rare' => l.rarityRare,
  'epic' => l.rarityEpic,
  'legendary' => l.rarityLegendary,
  'seasonal' => l.raritySeasonal,
  'tournament' => l.rarityTournament,
  _ => l.rarityCommon,
};

String rarityUpper(AppLocalizations l, String rarity) => switch (rarity) {
  'rare' => l.rarityRareUpper,
  'epic' => l.rarityEpicUpper,
  'legendary' => l.rarityLegendaryUpper,
  'seasonal' => l.raritySeasonalUpper,
  'tournament' => l.rarityTournamentUpper,
  _ => l.rarityCommonUpper,
};

/// "1 800 yaqut" / "250 sikkə".
String priceText(AppLocalizations l, Currency currency, int amount) =>
    currency == Currency.coins
        ? l.priceCoins(amount, formatAmount(amount))
        : l.priceGems(amount, formatAmount(amount));

/// Mission names by the counter they follow (`config/progression.php`);
/// unknown events get a generic label.
String missionName(AppLocalizations l, Mission m) => switch (m.event) {
  'doubles' => l.missionDoubles(m.target),
  'ranked_win' => l.missionRankedWin(m.target),
  'cube_take_win' => l.missionCubeTakeWin,
  'long_play' => l.missionPlayLong,
  'mars' => l.missionMars(m.target),
  'play' => l.missionPlay(m.target),
  'win' => l.missionWin(m.target),
  'puzzle_solved' => l.missionPuzzle(m.target),
  _ => l.missionGeneric,
};

/// Achievement ids of `config/progression.php`, in display order.
const achievementIds = [
  'first_win',
  'wins_10',
  'wins_100',
  'games_1000',
  'mars_10',
  'ranked_wins_25',
  'streak_10',
];

/// Title items granted by achievements (`config/progression.php`).
const titleAchievements = {
  'title.regular': 'wins_10',
  'title.veteran': 'wins_100',
  'title.mars_master': 'mars_10',
  'title.contender': 'ranked_wins_25',
};

String achievementName(AppLocalizations l, String id) => switch (id) {
  'first_win' => l.achFirstWin,
  'wins_10' => l.achWins10,
  'wins_100' => l.achWins100,
  'games_1000' => l.achGames1000,
  'mars_10' => l.achMars10,
  'ranked_wins_25' => l.achRankedWins25,
  'streak_10' => l.achStreak10,
  _ => l.achGeneric,
};

/// "5-ci gün" with the correct Azerbaijani suffix per day (store.md §6.6).
String streakDayLabel(AppLocalizations l, int day) => switch (Streak.cycleDay(
  day,
)) {
  1 => l.streakDay1,
  2 => l.streakDay2,
  3 => l.streakDay3,
  4 => l.streakDay4,
  5 => l.streakDay5,
  6 => l.streakDay6,
  _ => l.streakDay7,
};
