import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../clans/clan_rules.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import '../online/online_draft.dart';
import '../online/online_text.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import '../ui/social.dart';
import 'social_models.dart';
import 'social_providers.dart';
import 'social_socket.dart';

/// Who a player menu, report or block is about.
class PlayerRef {
  const PlayerRef({
    required this.id,
    required this.name,
    this.rating,
    this.inMyClan = false,
  });

  PlayerRef.of(PublicUser u, {this.inMyClan = false})
    : id = u.id,
      name = u.name,
      rating = u.bestRating;

  final String id;
  final String name;
  final int? rating;
  final bool inMyClan;

  PublicUser get user => PublicUser(id: id, name: name);
}

/// 14.1 player menu: add friend, invite, mute, report, block (and their
/// undo rows). [rankedGame] hides "invite" during a ranked game.
Future<void> showPlayerMenu(
  BuildContext context,
  PlayerRef player, {
  String? matchId,
  bool rankedGame = false,
}) => showNardSheet<void>(
  context,
  builder:
      (_) => _PlayerMenu(
        player: player,
        matchId: matchId,
        rankedGame: rankedGame,
        // The caller's context outlives the sheet (notes, pushes).
        host: context,
      ),
);

class _PlayerMenu extends ConsumerWidget {
  const _PlayerMenu({
    required this.player,
    required this.matchId,
    required this.rankedGame,
    required this.host,
  });

  final PlayerRef player;
  final String? matchId;
  final bool rankedGame;
  final BuildContext host;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final friends = ref.watch(friendsProvider).value;
    final blocked = ref.watch(blocksProvider).value ?? const [];
    final muted = ref.watch(mutedPlayersProvider).contains(player.id);
    final account = ref.watch(accountProvider).value;
    final isFriend = friends?.isFriend(player.id) ?? false;
    final requested = friends?.isRequested(player.id) ?? false;
    final isBlocked = blocked.any((u) => u.id == player.id);
    final clan = account?.clan;
    final canClanInvite =
        clan != null &&
        !player.inMyClan &&
        ClanPermissions.canInvite(clan.role);

    void close() => Navigator.of(context).pop();

    Future<void> run(Future<String?> Function() action) async {
      close();
      try {
        final note = await action();
        if (note != null && host.mounted) showNote(host, note);
      } on Object catch (e) {
        if (host.mounted) showNote(host, friendErrorText(l, e));
      }
    }

    final rows = <Widget>[
      if (!isFriend && !isBlocked && !requested)
        SheetActionRow(
          icon: LucideIcons.userPlus,
          label: l.playerMenuAddFriend,
          onTap:
              () => run(() async {
                final status = await ref
                    .read(friendsProvider.notifier)
                    .add(userId: player.id);
                return status == FriendRequestStatus.accepted
                    ? l.friendAccepted
                    : l.friendRequested;
              }),
        ),
      if (!rankedGame && !isBlocked)
        SheetActionRow(
          icon: LucideIcons.dice3,
          label: l.playerMenuInvite,
          onTap: () {
            close();
            final draft = ref.read(onlineDraftProvider);
            ref
                .read(socialSocketProvider.notifier)
                .createRoom(
                  draft.variant,
                  max(1, draft.matchLength),
                  invite: player.user,
                );
            unawaited(host.push('/room'));
          },
        ),
      if (canClanInvite && !isBlocked)
        SheetActionRow(
          icon: LucideIcons.shield,
          label: l.playerMenuInviteClan,
          onTap:
              () => run(() async {
                await ref
                    .read(apiClientProvider)
                    .inviteToClan(clan.id, player.id);
                return l.clanInvited;
              }),
        ),
      SheetActionRow(
        icon: LucideIcons.volumeX,
        label: muted ? l.playerMenuUnmute : l.playerMenuMute,
        onTap:
            () => run(() async {
              ref.read(mutedPlayersProvider.notifier).toggle(player.id);
              return muted ? l.unmutedNote : l.mutedNote;
            }),
      ),
      if (isFriend)
        SheetActionRow(
          icon: LucideIcons.userMinus,
          label: l.playerMenuUnfriend,
          onTap:
              () => run(() async {
                await ref.read(friendsProvider.notifier).unfriend(player.id);
                return l.friendRemoved;
              }),
        ),
      SheetActionRow(
        icon: LucideIcons.flag,
        label: l.playerMenuReport,
        danger: true,
        onTap: () {
          close();
          unawaited(
            host.push(
              '/report',
              extra: ReportArgs(player: player, matchId: matchId),
            ),
          );
        },
      ),
      SheetActionRow(
        icon: LucideIcons.ban,
        label: isBlocked ? l.playerMenuUnblock : l.playerMenuBlock,
        danger: !isBlocked,
        onTap: () async {
          if (isBlocked) {
            await run(() async {
              await ref.read(blocksProvider.notifier).unblock(player.id);
              return l.unblockDone;
            });
            return;
          }
          close();
          if (!host.mounted) return;
          await blockPlayer(host, ref, player);
        },
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Avatar(
              name: player.name,
              size: 72,
              tone: AvatarTone.opponent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            player.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NardType.title.copyWith(fontSize: 22, color: c.text),
          ),
          if (player.rating != null) ...[
            const SizedBox(height: 4),
            Text(
              l.rankMeta(player.rating!),
              textAlign: TextAlign.center,
              style: NardType.bodyS.copyWith(
                color: c.text.withValues(alpha: .7),
                fontFeatures: tabular,
              ),
            ),
          ],
          const SizedBox(height: 16),
          GroupCard(children: rows),
          const SizedBox(height: 10),
          NardButton(
            label: l.cancel,
            variant: NardButtonVariant.outline,
            onPressed: close,
          ),
        ],
      ),
    );
  }
}

/// 14.3 confirm, then `POST /blocks`; shows "{name} bloklandı." Returns
/// whether the player is now blocked.
Future<bool> blockPlayer(
  BuildContext context,
  WidgetRef ref,
  PlayerRef player,
) async {
  final l = AppLocalizations.of(context);
  final ok = await showBlockSheet(context, player.name);
  if (ok != true || !context.mounted) return false;
  try {
    await ref.read(blocksProvider.notifier).block(player.id);
    if (context.mounted) showNote(context, l.blockDone(player.name));
    return true;
  } on Object catch (e) {
    if (context.mounted) showNote(context, friendErrorText(l, e));
    return false;
  }
}

/// 14.3 block confirmation sheet.
Future<bool?> showBlockSheet(BuildContext context, String name) =>
    showNardSheet<bool>(
      context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        final c = ctx.nard;
        final path = [
          l.settingsTitle,
          l.settingsAccountPrivacy,
          l.privacyBlocked,
        ].join(' › ');
        Widget bullet(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(width: 6, height: 6, color: c.accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    color: c.text.withValues(alpha: .8),
                  ),
                ),
              ),
            ],
          ),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.blockTitle(name)),
            const SizedBox(height: 16),
            bullet(l.blockInfoMatchmaking),
            bullet(l.blockInfoContact),
            bullet(l.blockInfoUndo(path)),
            const SizedBox(height: 6),
            NardButton(
              label: l.blockConfirm,
              variant: NardButtonVariant.danger,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 10),
            NardButton(
              label: l.cancel,
              variant: NardButtonVariant.outline,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        );
      },
    );

/// Arguments of the 14.2 report screen.
class ReportArgs {
  const ReportArgs({required this.player, this.matchId});

  final PlayerRef player;
  final String? matchId;
}

/// 14.2 report reason.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.args});

  final ReportArgs args;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _note = TextEditingController();
  ReportReason? _reason;
  bool _alsoBlock = true;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _reasonText(AppLocalizations l, ReportReason r) => switch (r) {
    ReportReason.abuse => l.reportReasonAbuse,
    ReportReason.name => l.reportReasonName,
    ReportReason.cheating => l.reportReasonCheating,
    ReportReason.stalling => l.reportReasonStalling,
    ReportReason.leaving => l.reportReasonLeaving,
    ReportReason.other => l.reportReasonOther,
  };

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    final l = AppLocalizations.of(context);
    final p = widget.args.player;
    setState(() => _busy = true);
    try {
      await ref
          .read(apiClientProvider)
          .report(p.id, reason, matchId: widget.args.matchId, note: _note.text);
      var blocked = false;
      if (_alsoBlock) {
        try {
          await ref.read(blocksProvider.notifier).block(p.id);
          blocked = true;
        } on Object {
          // The report went through; blocking can be retried from 14.1.
        }
      }
      if (!mounted) return;
      context.pushReplacement(
        '/report/sent',
        extra: (name: p.name, blocked: blocked),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      final limited = e is ApiException && e.status == 429;
      showNote(context, limited ? l.reportLimit : friendErrorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final name = widget.args.player.name;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.reportTitle(name), bare: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Overline(
                      l.reportReasonLabel,
                      color: c.text.withValues(alpha: .55),
                    ),
                  ),
                  GroupCard(
                    children: [
                      for (final r in ReportReason.values)
                        Semantics(
                          selected: _reason == r,
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _reason = r),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 50),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              color:
                                  _reason == r
                                      ? c.accent.withValues(alpha: .1)
                                      : null,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _reasonText(l, r),
                                      style: NardType.body.copyWith(
                                        color: c.text,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  RadioDot(selected: _reason == r),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  NardMultilineField(
                    controller: _note,
                    hint: l.reportNoteHint,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    checked: _alsoBlock,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _alsoBlock = !_alsoBlock),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            NardCheckbox(checked: _alsoBlock),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l.reportAlsoBlock,
                                style: NardType.body.copyWith(color: c.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      l.reportDisclosure(name),
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        height: 17 / 12,
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: NardButton(
                label: l.reportSend,
                onPressed: _reason == null || _busy ? null : _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 14.4 report sent.
class ReportSentScreen extends StatelessWidget {
  const ReportSentScreen({
    super.key,
    required this.name,
    required this.blocked,
  });

  final String name;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final body =
        blocked ? '${l.reportSentBody} ${l.blockDone(name)}' : l.reportSentBody;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.success.withValues(alpha: .16),
                        border: Border.all(
                          color: c.successText.withValues(alpha: .4),
                        ),
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: 40,
                        color: c.successText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.reportSentTitle,
                      textAlign: TextAlign.center,
                      style: NardType.title.copyWith(
                        fontSize: 24,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        height: 21 / 14,
                        color: c.text.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: NardButton(
                label: l.close,
                variant: NardButtonVariant.outline,
                onPressed:
                    () =>
                        context.canPop() ? context.pop() : context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
