import 'package:intl/intl.dart';
import 'package:nard_core/nard_core.dart';

import '../l10n/gen/app_localizations.dart';
import 'api_client.dart';
import 'rank.dart';

/// Localized helpers shared by the online screens.
extension OnlineText on AppLocalizations {
  String tierName(Tier tier) => switch (tier) {
    Tier.bronze => tierBronze,
    Tier.silver => tierSilver,
    Tier.gold => tierGold,
    Tier.platinum => tierPlatinum,
    Tier.diamond => tierDiamond,
    Tier.master => tierMaster,
    Tier.grandmaster => tierGrandmaster,
  };

  /// "Platin II" (grandmaster has no sub-level).
  String rankName(Tier tier, int? sub) =>
      sub == null
          ? tierName(tier)
          : rankWithSub(tierName(tier), subNumeral(sub));

  /// Rank of a rating, e.g. "Platin II".
  String rankOf(int rating) => rankName(tierOf(rating), subLevel(rating));

  /// "Platin II · 1866".
  String rankMeta(int rating) => profileMeta(rankOf(rating), rating);

  String formatName(int matchLength) =>
      matchLength <= 1 ? formatOneGame : formatPoints(matchLength);

  String variantAbbr(Variant v) =>
      v == Variant.shortNard ? variantShortAbbr : variantLongAbbr;

  String signedDelta(int delta) =>
      delta >= 0 ? ratingDeltaUp(delta) : ratingDeltaDown(-delta);

  /// "bu gün", "dünən" or a short locale date.
  String relativeDate(DateTime date, DateTime now) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return dateToday;
    if (diff == 1) return dateYesterday;
    return DateFormat.MMMd(localeName).format(date);
  }
}

/// "0:07".
String formatDuration(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Rating info of [variant], if the player has one.
RatingInfo? ratingFor(Account? account, Variant variant) =>
    account?.ratings[variant.name];
