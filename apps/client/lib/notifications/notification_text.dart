import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/online_text.dart';
import '../online/rank.dart';
import '../theme/nard_colors.dart';
import 'notification_models.dart';
import 'notification_providers.dart' show challengeControl;

/// A 16.2 row: [who] in bold, then [text] (notifications.md §3).
typedef NotificationLine = ({String who, String text});

NotificationLine notificationLine(
  AppLocalizations l,
  String locale,
  AppNotification n,
) {
  final from = n.from?.name ?? '';
  final names = n.names('tournament');
  final tournament =
      names[locale] ?? names['en'] ?? (names.isEmpty ? '' : names.values.first);
  final tier = Tier.values.asNameMap()[n.text('tier')];
  return switch (n.type) {
    NotificationType.friendRequest => (who: from, text: l.notifFriendRequest),
    NotificationType.friendAccepted => (who: from, text: l.notifFriendAccepted),
    NotificationType.challenge => (
      who: from,
      text: l.notifChallenge(
        n.text('variant') == 'longNard' ? l.variantLong : l.variantShort,
        n.number('matchLength'),
        l.controlWithClock(challengeControl(n)),
      ),
    ),
    NotificationType.clanInvite => (
      who: from,
      text: l.notifClanInvite(n.text('clan'), n.text('tag')),
    ),
    NotificationType.clanJoined => (
      who: n.text('clan'),
      text: l.notifClanJoined,
    ),
    NotificationType.clanWar => (
      who: l.notifClanWarWho,
      text: l.notifClanWar(n.text('opponent'), n.text('tag')),
    ),
    NotificationType.tournamentReminder => (
      who: tournament,
      text: l.notifTournamentReminder(n.number('minutes')),
    ),
    NotificationType.tournamentStarted => (
      who: tournament,
      text: l.notifTournamentStarted,
    ),
    NotificationType.tournamentRound => (
      who: tournament,
      text: l.notifTournamentRound(n.number('round'), n.text('opponent')),
    ),
    NotificationType.tournamentEliminated => (
      who: tournament,
      text:
          n.number('place') > 0
              ? l.notifTournamentEliminatedPlace(
                n.number('round'),
                n.number('place'),
              )
              : l.notifTournamentEliminated(n.number('round')),
    ),
    NotificationType.tournamentWon => (
      who: tournament,
      text: l.notifTournamentWon,
    ),
    NotificationType.tournamentFinished => (
      who: tournament,
      text: l.notifTournamentFinished(n.number('place')),
    ),
    NotificationType.tournamentCancelled => (
      who: tournament,
      text:
          n.number('refund') > 0
              ? l.notifTournamentCancelledRefund(n.number('refund'))
              : l.notifTournamentCancelled,
    ),
    NotificationType.seasonEnd => (
      who: l.notifSeasonEndWho(n.number('season')),
      text:
          n.number('rank') > 0
              ? l.notifSeasonEndRank(
                tier == null ? '' : l.tierName(tier),
                n.number('rank'),
                n.number('coins'),
              )
              : l.notifSeasonEnd(tier == null ? '' : l.tierName(tier)),
    ),
    NotificationType.seasonStarted => (
      who: l.notifSeasonEndWho(n.number('season')),
      text: l.notifSeasonStarted,
    ),
    NotificationType.levelUp => (
      who: l.notifLevelUpWho(n.number('level')),
      text: l.notifLevelUp(n.number('coins')),
    ),
    NotificationType.moderationWarning => (
      who: l.notifModerationWarningWho,
      text:
          n.text('reason').trim().isEmpty
              ? l.notifModerationWarningPlain
              : l.notifModerationWarning(n.text('reason').trim()),
    ),
    NotificationType.unknown => (who: '', text: l.notifUnknown),
  };
}

IconData notificationIcon(NotificationType t) => switch (t) {
  NotificationType.friendRequest => LucideIcons.userPlus,
  NotificationType.friendAccepted => LucideIcons.userCheck,
  NotificationType.challenge => LucideIcons.dices,
  NotificationType.clanInvite ||
  NotificationType.clanJoined => LucideIcons.users,
  NotificationType.clanWar => LucideIcons.swords,
  NotificationType.tournamentReminder ||
  NotificationType.tournamentStarted ||
  NotificationType.tournamentRound ||
  NotificationType.tournamentEliminated ||
  NotificationType.tournamentWon ||
  NotificationType.tournamentFinished ||
  NotificationType.tournamentCancelled => LucideIcons.trophy,
  NotificationType.seasonEnd ||
  NotificationType.seasonStarted => LucideIcons.award,
  NotificationType.levelUp => LucideIcons.sparkles,
  NotificationType.moderationWarning => LucideIcons.shieldAlert,
  NotificationType.unknown => LucideIcons.bell,
};

/// Game and competition icons are brass, social ones ivory (16.2 mock).
Color notificationIconColor(NardColors c, NotificationType t) => switch (t) {
  NotificationType.friendRequest ||
  NotificationType.friendAccepted ||
  NotificationType.clanInvite ||
  NotificationType.clanJoined ||
  NotificationType.unknown => c.text,
  NotificationType.moderationWarning => c.dangerText,
  _ => c.accent,
};
