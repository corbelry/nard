import 'clan_models.dart';

/// Clan numbers mirrored from `apps/api/config/clans.php` (ADR-036). The
/// server re-checks everything; these only drive the UI.
abstract final class ClanRules {
  static const createPrice = 3000;
  static const renamePrice = 1000;
  static const nameMin = 3;
  static const nameMax = 24;
  static const tagMin = 3;
  static const tagMax = 5;
  static const descriptionMax = 200;
  static const chatMax = 300;
  static const minDonation = 10;
  static const languages = ['az', 'tr', 'ru', 'en'];

  /// Min-rating slider: 0 = anyone ("Hamı"), then 1000–2400 by 50
  /// (social.md §13.18 proposal; API allows 0–2400).
  static const ratingFloor = 1000;
  static const ratingMax = 2400;
  static const ratingStep = 50;

  static final _tag = RegExp(r'^[A-Z]{3,5}$');
  static final _name = RegExp(
    r"^[\p{L}\p{N}][\p{L}\p{N} _'.\-]*$",
    unicode: true,
  );

  /// The name as the API stores it: trimmed, inner spaces collapsed.
  static String normalizeName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  static bool validName(String name) {
    final n = normalizeName(name);
    return n.length >= nameMin && n.length <= nameMax && _name.hasMatch(n);
  }

  /// Tags are 3–5 letters A–Z (stored uppercase).
  static bool validTag(String tag) => _tag.hasMatch(tag.trim().toUpperCase());

  /// Keeps only A–Z (upper-cased), at most [tagMax] letters.
  static String cleanTag(String input) {
    final letters = input.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    return letters.length > tagMax ? letters.substring(0, tagMax) : letters;
  }

  /// Step 1 (19.1) can continue: valid name and a valid, free tag.
  static bool canContinue(ClanDraft d, {required bool? tagAvailable}) =>
      validName(d.name) && validTag(d.tag) && tagAvailable == true;

  /// Step 2 (19.2) can submit: enough coins.
  static bool canAfford(int coins) => coins >= createPrice;
}

/// What a role may do (ADR-036, `ClanService`): roles stack; kicks and
/// role changes only on members strictly below you.
abstract final class ClanPermissions {
  static bool canSeeRequests(ClanRole? r) => r != null && r >= ClanRole.elder;

  static bool canAcceptRequest(ClanRole? r) => canSeeRequests(r);

  static bool canDeclineRequest(ClanRole? r) =>
      r != null && r >= ClanRole.coLeader;

  static bool canInvite(ClanRole? r) => r != null && r >= ClanRole.elder;

  static bool canKick(ClanRole? actor, ClanRole target) =>
      actor != null && actor >= ClanRole.elder && actor > target;

  /// Roles [actor] may give [target] (excluding the current one); leader
  /// transfer is separate ([canTransfer]).
  static List<ClanRole> assignableRoles(ClanRole? actor, ClanRole target) {
    if (actor == null || actor < ClanRole.coLeader || !(actor > target)) {
      return const [];
    }
    return [
      for (final r in ClanRole.values)
        if (r != ClanRole.leader && actor > r && r != target) r,
    ];
  }

  static bool canTransfer(ClanRole? actor) => actor == ClanRole.leader;

  static bool canEdit(ClanRole? r) => r != null && r >= ClanRole.coLeader;

  /// Name/tag changes cost coins and are the leader's.
  static bool canRename(ClanRole? r) => r == ClanRole.leader;

  static bool canDeleteMessage(ClanRole? actor, {required bool own}) =>
      own || (actor != null && actor >= ClanRole.elder);

  /// A leader with other members must hand over leadership first.
  static bool mustTransferBeforeLeaving(ClanRole? r, int memberCount) =>
      r == ClanRole.leader && memberCount > 1;
}
