import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nard_core/nard_core.dart' show Variant;

import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart' show ApiException;
import '../online/online_text.dart';
import '../theme/nard_colors.dart';
import 'tournament_models.dart';

/// Localized tournament labels (tournaments.md §1–§7).

/// An ordinal place: az "1-ci", "3-cü", "6-cı", "9-cu"; en "1st"; ru
/// "1-е"; tr "1." (suffix harmony §19.29).
String ordinal(String locale, int n) {
  switch (locale) {
    case 'az':
      return '$n-${_azSuffix(n)}';
    case 'en':
      final mod100 = n % 100;
      final suffix =
          mod100 >= 11 && mod100 <= 13
              ? 'th'
              : switch (n % 10) {
                1 => 'st',
                2 => 'nd',
                3 => 'rd',
                _ => 'th',
              };
      return '$n$suffix';
    case 'ru':
      return '$n-е';
    default:
      return '$n.';
  }
}

/// Vowel harmony of the Azerbaijani ordinal suffix by the last spoken
/// part of the number.
String _azSuffix(int n) {
  if (n == 0) return 'cı';
  if (n % 1000000 == 0) return 'cu';
  if (n % 1000 == 0) return 'ci';
  if (n % 100 == 0) return 'cü';
  final ones = n % 10;
  if (ones != 0) {
    return switch (ones) {
      1 || 2 || 5 || 7 || 8 => 'ci',
      3 || 4 => 'cü',
      6 => 'cı',
      _ => 'cu',
    };
  }
  return switch (n % 100 ~/ 10) {
    1 || 3 => 'cu',
    4 || 6 || 9 => 'cı',
    _ => 'ci',
  };
}

/// "Final", "1/4" …; Swiss / round-robin rounds stay numbers.
String stageLabel(AppLocalizations l, String stage) {
  if (stage == 'final') return l.roundFinal;
  if (stage.startsWith('1/')) {
    final n = int.tryParse(stage.substring(2));
    if (n != null) return l.roundOf(n);
  }
  final n = int.tryParse(stage);
  return n == null ? stage : l.tourNow(n);
}

/// Knockout stage of [round] out of [total] rounds.
String knockoutStage(int total, int round) =>
    round >= total ? 'final' : '1/${1 << (total - round)}';

String typeName(AppLocalizations l, Tournament t) => switch (t.type) {
  TournamentType.knockout => l.tourFormatKnockout,
  TournamentType.swiss => l.tourFormatSwiss,
  TournamentType.roundRobin => l.tourFormatRoundRobin,
};

String typeUpper(AppLocalizations l, Tournament t) =>
    t.kind == TournamentKind.sitAndGo
        ? l.tourTypeSngUpper
        : switch (t.type) {
          TournamentType.knockout => l.tourTypeKnockoutUpper,
          TournamentType.swiss => l.tourTypeSwissUpper,
          TournamentType.roundRobin => l.tourTypeRoundRobinUpper,
        };

String variantName(AppLocalizations l, Variant v) =>
    v == Variant.shortNard ? l.variantShort : l.variantLong;

/// 4.1 meta: "Qısa · 5 xal", "Uzun · İsveç · 7 raund".
String tournamentMeta(AppLocalizations l, Tournament t) {
  final base = l.tourMeta(l.variantAbbr(t.variant), t.matchLength);
  if (t.type == TournamentType.knockout) return base;
  final rounds = t.totalRounds;
  return [
    base,
    typeName(l, t),
    if (rounds != null) l.tourRounds(rounds),
  ].join(' · ');
}

/// Status overline text and colour.
(String, Color, bool) statusLabel(
  AppLocalizations l,
  NardColors c,
  Tournament t,
) => switch (t.status) {
  TournamentStatus.running => (
    l.tourStatusLive(t.currentRound.clamp(1, 99)),
    c.dangerText,
    true,
  ),
  TournamentStatus.registering => (l.tourStatusOpen, c.accentHi, false),
  TournamentStatus.finished => (
    l.tourStatusFinished,
    c.text.withValues(alpha: .6),
    false,
  ),
  TournamentStatus.cancelled => (
    l.tourStatusCancelled,
    c.text.withValues(alpha: .45),
    false,
  ),
};

/// The right slot of a 4.1 card: countdown under 24 h, "Sabah 20:00",
/// weekday + time later; my place once finished.
String timeSlot(AppLocalizations l, Tournament t, DateTime now, String locale) {
  if (t.status == TournamentStatus.finished) {
    final place = t.myPlace;
    return place == null ? '' : l.tourPlace(ordinal(locale, place));
  }
  if (t.status == TournamentStatus.running) {
    return t.myStatus == MyTournamentStatus.eliminated
        ? l.tourOut(stageForCurrent(l, t))
        : stageForCurrent(l, t);
  }
  final at = t.startsAt ?? t.expiresAt;
  if (at == null) return '';
  final left = at.difference(now);
  if (left.isNegative) return '';
  if (left.inHours < 24) return formatCountdown(left);
  final time = DateFormat.Hm(locale).format(at);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  if (at.year == tomorrow.year &&
      at.month == tomorrow.month &&
      at.day == tomorrow.day) {
    return l.tourTomorrowAt(time);
  }
  return '${DateFormat.E(locale).format(at)} $time';
}

/// The running round as "1/8" / "Final" (knockout) or "Raund 3".
String stageForCurrent(AppLocalizations l, Tournament t) {
  final total = t.totalRounds;
  final round = t.currentRound.clamp(1, 99);
  if (t.type == TournamentType.knockout && total != null) {
    return stageLabel(l, knockoutStage(total, round));
  }
  return l.tourNow(round);
}

/// Prize tiles of 4.2: "1-ci" · "2-ci" · "3–4" → coins.
List<(String, String)> prizeTiles(Tournament t, String locale) => [
  for (final p in t.prizes)
    if (p.coins > 0)
      (
        p.from == p.to ? ordinal(locale, p.from) : '${p.from}–${p.to}',
        formatAmount(p.coins),
      ),
];

/// Message for a failed tournament action (422 codes of the contract).
String tournamentError(AppLocalizations l, Object e) {
  if (e is ApiException) {
    if (e.offline) return l.onlineOfflineTitle;
    return switch (e.code) {
      'full' => l.tourFull,
      'closed' => l.tourClosed,
      'rating_too_low' => l.tourRatingTooLow,
      'insufficient_coins' || 'insufficient_funds' => l.purchaseNotEnoughCoins,
      'invite_required' => l.tourInviteRequired,
      'not_found' => l.privateTourCodeNotFound,
      'too_many_open' => l.privateTourTooMany,
      'not_enough_players' => l.privateTourNotEnough,
      _ => l.tourActionFailed,
    };
  }
  return l.tourActionFailed;
}

/// Invite codes are shown 3-3 ("K7Q-29M"); the hyphen is display only.
String displayCode(String code) =>
    code.length == 6 ? '${code.substring(0, 3)}-${code.substring(3)}' : code;

/// "t12-3-4" → table 5 (slot + 1); null when the id has another shape.
int? tableOf(String matchId) {
  final parts = matchId.split('-');
  if (parts.length != 3) return null;
  final slot = int.tryParse(parts[2]);
  return slot == null ? null : slot + 1;
}
