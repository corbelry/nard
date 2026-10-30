import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/online_draft.dart';
import '../online/online_text.dart';
import '../online/reachability.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'player_menu.dart';
import 'social_gate.dart';
import 'social_models.dart';
import 'social_providers.dart';
import 'social_socket.dart';
import 'spectate.dart';

PresenceDot presenceDot(Presence p) => switch (p) {
  Presence.online => PresenceDot.online,
  Presence.inGame => PresenceDot.inGame,
  Presence.offline => PresenceDot.offline,
};

String presenceText(AppLocalizations l, Presence p) => switch (p) {
  Presence.online => l.presenceOnline,
  Presence.inGame => l.presenceInGame,
  Presence.offline => l.presenceOffline,
};

/// Opens 6.4 for a friend's running game.
void watchFriend(BuildContext context, WidgetRef ref, String matchId) {
  final l = AppLocalizations.of(context);
  ref
      .read(spectatorProvider.notifier)
      .watch(matchId, whiteName: l.hotseatWhite, blackName: l.hotseatBlack);
  unawaited(context.push('/spectate'));
}

/// Hosts a private room and challenges [friend] (6.1 "Çağır").
void inviteFriend(BuildContext context, WidgetRef ref, PublicUser friend) {
  final draft = ref.read(onlineDraftProvider);
  ref
      .read(socialSocketProvider.notifier)
      .createRoom(draft.variant, max(1, draft.matchLength), invite: friend);
  unawaited(context.push('/room'));
}

/// 6.1 Friends: requests, challenges, then friends (available first) with
/// presence; "Çağır" hosts a room for them, "İzlə" spectates.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  Timer? _presence;

  /// Presence refresh while visible (social.md §2.1 proposal).
  static const presenceEvery = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _presence = Timer.periodic(presenceEvery, (_) => _queryPresence());
    WidgetsBinding.instance.addPostFrameCallback((_) => _queryPresence());
  }

  @override
  void dispose() {
    _presence?.cancel();
    super.dispose();
  }

  void _queryPresence() {
    if (!mounted) return;
    final friends = ref.read(friendsProvider).value?.friends ?? const [];
    // Everyone: players in a game may not have hit the API for a while.
    final ids = [for (final f in friends) f.user.id];
    ref.read(socialSocketProvider.notifier).queryPresence(ids);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    ref.listen(friendsProvider, (_, next) {
      if (next.hasValue) _queryPresence();
    });
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.bgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OfflineBanner(
                text: l.offlineBanner,
                visible: ref.watch(offlineProvider),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
                child: Row(
                  children: [
                    Pressable(
                      onTap: () => Navigator.of(context).maybePop(),
                      semanticLabel:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20,
                        color: c.text,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.friendsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.displayL.copyWith(
                          fontSize: 26,
                          color: c.text,
                        ),
                      ),
                    ),
                    SmallActionButton(
                      label: l.friendsAdd,
                      icon: LucideIcons.plus,
                      style: SmallButtonStyle.strong,
                      onTap: () => context.push('/friends/add'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SocialGate(
                  builder:
                      (context, _) => AsyncBody<FriendsOverview?>(
                        value: ref.watch(friendsProvider),
                        onRetry: () => ref.invalidate(friendsProvider),
                        data: (data) => _list(context, l, data!),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations l, FriendsOverview d) {
    final c = context.nard;
    final matches = ref.watch(presenceProvider);
    final room = ref.watch(socialSocketProvider);
    if (d.friends.isEmpty &&
        d.incoming.isEmpty &&
        d.outgoing.isEmpty &&
        d.challenges.isEmpty) {
      return MessageState(
        title: l.friendsEmptyTitle,
        body: l.friendsEmptyBody,
        action: l.addFriendTitle,
        onAction: () => context.push('/friends/add'),
      );
    }
    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Overline(title, color: c.text.withValues(alpha: .55)),
    );
    final sorted = sortByPresence(d.friends.map((f) => f.user), matches);
    final joining = room.phase == RoomPhase.joining;
    return RefreshIndicator(
      color: c.accent,
      onRefresh: () => refreshFriends(ref),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (d.challenges.isNotEmpty) section(l.friendChallengesTitle),
          for (final ch in d.challenges)
            _UserRow(
              user: ch.from,
              status: l.challengeMeta(
                ch.variant == Variant.shortNard
                    ? l.variantShort
                    : l.variantLong,
                l.formatName(ch.matchLength),
              ),
              statusColor: c.accentHi,
              action: SmallActionButton(
                label: l.roomJoin,
                busy: joining && room.code == ch.code,
                onTap:
                    joining
                        ? null
                        : () {
                          ref
                              .read(socialSocketProvider.notifier)
                              .joinRoom(
                                ch.code,
                                variant: ch.variant,
                                matchLength: ch.matchLength,
                              );
                          context.push('/room/join?code=${ch.code}');
                        },
              ),
            ),
          if (d.incoming.isNotEmpty) section(l.friendRequestsTitle),
          for (final r in d.incoming)
            _UserRow(
              user: r.user,
              status: _meta(l, r.user),
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmallActionButton(
                    label: l.friendAccept,
                    onTap:
                        () => _act(
                          ref
                              .read(friendsProvider.notifier)
                              .accept(r.requestId),
                        ),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: LucideIcons.x,
                    label: l.friendDismiss,
                    onTap:
                        () => _act(
                          ref
                              .read(friendsProvider.notifier)
                              .dismiss(r.requestId),
                        ),
                  ),
                ],
              ),
            ),
          if (sorted.isNotEmpty &&
              (d.incoming.isNotEmpty || d.challenges.isNotEmpty))
            section(l.friendsSection),
          for (final u in sorted) _friendRow(context, l, u, matches),
          if (d.outgoing.isNotEmpty) section(l.friendSentTitle),
          for (final r in d.outgoing)
            _UserRow(
              user: r.user,
              status: l.friendRequested,
              dim: true,
              action: _IconAction(
                icon: LucideIcons.x,
                label: l.friendCancelRequest,
                onTap:
                    () => _act(
                      ref.read(friendsProvider.notifier).dismiss(r.requestId),
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Center(
              child: Pressable(
                onTap: () => context.push('/friends/blocked'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    l.privacyBlocked,
                    style: NardType.bodyS.copyWith(
                      color: c.text.withValues(alpha: .55),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _act(Future<void> action) async {
    final l = AppLocalizations.of(context);
    try {
      await action;
    } on Object catch (e) {
      if (mounted) showNote(context, friendErrorText(l, e));
    }
  }

  String _meta(AppLocalizations l, PublicUser u) {
    final rating = u.bestRating;
    final base = rating == null ? l.levelShort(u.level) : l.rankMeta(rating);
    final clan = u.clan;
    return clan == null ? base : l.metaWithClan(base, l.clanTag(clan.tag));
  }

  Widget _friendRow(
    BuildContext context,
    AppLocalizations l,
    PublicUser u,
    Map<String, String> matches,
  ) {
    final c = context.nard;
    final p = presenceOf(u, matches);
    final matchId = matches[u.id];
    final Widget action = switch (p) {
      Presence.inGame => SmallActionButton(
        label: l.friendWatch,
        style: SmallButtonStyle.outline,
        onTap:
            matchId == null ? null : () => watchFriend(context, ref, matchId),
      ),
      Presence.online => SmallActionButton(
        label: l.friendInvite,
        onTap: () => inviteFriend(context, ref, u),
      ),
      Presence.offline => SmallActionButton(
        label: l.friendInvite,
        style: SmallButtonStyle.outline,
        onTap: () => inviteFriend(context, ref, u),
      ),
    };
    return _UserRow(
      user: u,
      presence: p,
      status: presenceText(l, p),
      statusColor: switch (p) {
        Presence.online => c.successText,
        Presence.inGame => c.accentHi,
        Presence.offline => c.text.withValues(alpha: .55),
      },
      dim: p == Presence.offline,
      action: action,
      onTap: () => showPlayerMenu(context, PlayerRef.of(u)),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: Center(
      child: Icon(
        icon,
        size: 18,
        color: context.nard.text.withValues(alpha: .6),
      ),
    ),
  );
}

/// Friend / request row (6.1): avatar 42, name, status, action.
class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.status,
    required this.action,
    this.presence,
    this.statusColor,
    this.dim = false,
    this.onTap,
  });

  final PublicUser user;
  final String status;
  final Widget action;
  final Presence? presence;
  final Color? statusColor;
  final bool dim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return HairlineRow(
      height: 64,
      onTap: onTap,
      semanticLabel: user.name,
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: dim ? .7 : 1,
              child: Row(
                children: [
                  PresenceAvatar(
                    name: user.name,
                    size: 42,
                    presence: presence == null ? null : presenceDot(presence!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.labelM.copyWith(color: c.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: statusColor ?? c.text.withValues(alpha: .6),
                            fontFeatures: tabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          action,
        ],
      ),
    );
  }
}

/// 15.1 › Bloklananlar (not designed): rows with "Bloku götür".
class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.privacyBlocked, bare: true),
            Expanded(
              child: AsyncBody<List<PublicUser>?>(
                value: ref.watch(blocksProvider),
                onRetry: () => ref.invalidate(blocksProvider),
                data: (users) {
                  final list = users ?? const [];
                  if (list.isEmpty) {
                    return MessageState(title: l.blockedEmpty, body: '');
                  }
                  return ListView(
                    children: [
                      for (final u in list)
                        _UserRow(
                          user: u,
                          status: l.levelShort(u.level),
                          action: SmallActionButton(
                            label: l.playerMenuUnblock,
                            style: SmallButtonStyle.outline,
                            onTap: () async {
                              try {
                                await ref
                                    .read(blocksProvider.notifier)
                                    .unblock(u.id);
                                if (context.mounted) {
                                  showNote(context, l.unblockDone);
                                }
                              } on Object catch (e) {
                                if (context.mounted) {
                                  showNote(context, friendErrorText(l, e));
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
