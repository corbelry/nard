import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart' show Currency;
import '../cosmetics/cosmetics_text.dart' show formatAmount;
import '../l10n/gen/app_localizations.dart';
import '../moderation/moderation.dart' show formatModerationTime;
import '../online/account.dart';
import '../social/player_menu.dart';
import '../social/social_gate.dart';
import '../social/social_models.dart';
import '../social/social_providers.dart';
import '../store/inventory.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart' show CurrencyIcon;
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_providers.dart';
import 'clan_rules.dart';
import 'clan_text.dart';
import 'clan_war_view.dart';

/// 5.4 Clan home: header, Söhbət · Fəaliyyət · Döyüş · Sandıq tabs,
/// weekly chest card; the ☰ menu leads to members, ranking, profile,
/// emblem, requests, invites and leaving.
class ClanHome extends ConsumerStatefulWidget {
  const ClanHome({super.key, required this.clanId});

  final String clanId;

  @override
  ConsumerState<ClanHome> createState() => _ClanHomeState();
}

class _ClanHomeState extends ConsumerState<ClanHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(clanDetailProvider(widget.clanId));
    return AsyncBody<ClanDetail>(
      value: detail,
      onRetry: () => ref.invalidate(clanDetailProvider(widget.clanId)),
      data:
          (d) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, l, d),
              UnderlineTabs(
                labels: [
                  l.clanTabChat,
                  l.clanTabActivity,
                  l.clanTabWar,
                  l.clanTabChest,
                ],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              if (_tab != 3 && d.chest != null)
                _ChestCard(
                  chest: d.chest!,
                  onTap: () => setState(() => _tab = 3),
                ),
              Expanded(
                child: switch (_tab) {
                  0 => ClanChatView(detail: d),
                  1 => ClanChatView(detail: d, activity: true),
                  2 => ClanWarView(clanId: d.id),
                  _ => ClanChestView(detail: d),
                },
              ),
            ],
          ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l, ClanDetail d) {
    final c = context.nard;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 12),
      child: Row(
        children: [
          ClanEmblem(
            emblem: d.summary.emblem,
            width: 40,
            initials:
                d.summary.emblem.symbol == 'initials'
                    ? clanInitials(d.summary.name)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.summary.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.title.copyWith(color: c.text),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.successText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l.clanOnline(d.onlineCount),
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.successText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Pressable(
            onTap: () => showClanMenu(context, ref, d),
            semanticLabel: l.actionMenu,
            child: Center(
              child: Icon(LucideIcons.menu, size: 22, color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5.4 clan menu (not designed, proposal list).
Future<void> showClanMenu(
  BuildContext context,
  WidgetRef ref,
  ClanDetail d,
) async {
  final l = AppLocalizations.of(context);
  final role = d.myRole;
  final id = d.id;
  final action = await showNardSheet<String>(
    context,
    builder:
        (ctx) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GroupCard(
                children: [
                  SheetActionRow(
                    icon: LucideIcons.users,
                    label: l.clanMenuMembers,
                    onTap: () => Navigator.of(ctx).pop('members'),
                  ),
                  SheetActionRow(
                    icon: LucideIcons.trophy,
                    label: l.clanMenuLeaderboard,
                    onTap: () => Navigator.of(ctx).pop('leaderboard'),
                  ),
                  SheetActionRow(
                    icon: LucideIcons.shield,
                    label: l.clanMenuProfile,
                    onTap: () => Navigator.of(ctx).pop('profile'),
                  ),
                  if (ClanPermissions.canEdit(role))
                    SheetActionRow(
                      icon: LucideIcons.pencil,
                      label: l.clanMenuEmblem,
                      onTap: () => Navigator.of(ctx).pop('emblem'),
                    ),
                  if (ClanPermissions.canSeeRequests(role))
                    SheetActionRow(
                      icon: LucideIcons.mail,
                      label: l.clanMenuRequests,
                      onTap: () => Navigator.of(ctx).pop('requests'),
                    ),
                  if (ClanPermissions.canInvite(role))
                    SheetActionRow(
                      icon: LucideIcons.userPlus,
                      label: l.clanMenuInvite,
                      onTap: () => Navigator.of(ctx).pop('invite'),
                    ),
                  SheetActionRow(
                    icon: LucideIcons.logOut,
                    label: l.clanMenuLeave,
                    danger: true,
                    onTap: () => Navigator.of(ctx).pop('leave'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              NardButton(
                label: l.cancel,
                variant: NardButtonVariant.outline,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'members':
      unawaited(context.push('/clans/$id/members'));
    case 'leaderboard':
      unawaited(context.push('/clans/leaderboard'));
    case 'profile':
      unawaited(context.push('/clans/$id'));
    case 'requests':
      unawaited(context.push('/clans/$id/requests'));
    case 'emblem':
      final emblem = await context.push<Emblem>(
        '/clans/emblem',
        extra: d.summary.emblem,
      );
      if (emblem == null || !context.mounted) return;
      try {
        await ref.read(apiClientProvider).updateClan(id, {
          'emblem': emblem.toJson(),
        });
        ref.invalidate(clanDetailProvider(id));
        await refreshMembership(ref);
      } on Object catch (e) {
        if (context.mounted) showNote(context, clanErrorText(l, e));
      }
    case 'invite':
      final friend = await showNardSheet<PublicUser>(
        context,
        builder: (_) => const FriendPickerSheet(),
      );
      if (friend == null || !context.mounted) return;
      try {
        await ref.read(apiClientProvider).inviteToClan(id, friend.id);
        if (context.mounted) showNote(context, l.clanInvited);
      } on Object catch (e) {
        if (context.mounted) showNote(context, clanErrorText(l, e));
      }
    case 'leave':
      await _leave(context, ref, d);
  }
}

Future<void> _leave(BuildContext context, WidgetRef ref, ClanDetail d) async {
  final l = AppLocalizations.of(context);
  final count = d.members.length;
  if (ClanPermissions.mustTransferBeforeLeaving(d.myRole, count)) {
    showNote(context, l.clanTransferFirst);
    return;
  }
  final ok = await showNardSheet<bool>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.clanLeaveTitle),
            const SizedBox(height: 8),
            Text(
              count <= 1 ? l.clanLeaveLastBody : l.clanLeaveBody,
              style: NardType.body.copyWith(
                fontSize: 14,
                color: ctx.nard.text.withValues(alpha: .8),
              ),
            ),
            const SizedBox(height: 18),
            NardButton(
              label: l.clanMenuLeave,
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
        ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref.read(apiClientProvider).leaveClan(d.id);
    await refreshMembership(ref);
  } on Object catch (e) {
    if (context.mounted) showNote(context, clanErrorText(l, e));
  }
}

/// Friends list sheet (clan invites).
class FriendPickerSheet extends ConsumerWidget {
  const FriendPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final friends = ref.watch(friendsProvider).value?.friends ?? const [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.clanMenuInvite),
        const SizedBox(height: 12),
        if (friends.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l.friendsEmptyTitle,
              textAlign: TextAlign.center,
              style: NardType.body.copyWith(color: c.textDim),
            ),
          ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final f in friends)
                HairlineRow(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onTap: () => Navigator.of(context).pop(f.user),
                  semanticLabel: f.user.name,
                  child: Row(
                    children: [
                      PresenceAvatar(name: f.user.name, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.labelM.copyWith(color: c.text),
                        ),
                      ),
                      if (f.user.clan != null)
                        Text(
                          l.clanTag(f.user.clan!.tag),
                          style: NardType.mono.copyWith(color: c.accent),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The 36 × 32 chest glyph (drawn, not an icon).
class ChestGlyph extends StatelessWidget {
  const ChestGlyph({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: 36 * scale,
      height: 32 * scale,
      decoration: BoxDecoration(
        gradient: c.chestFill,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6 * scale),
          topRight: Radius.circular(6 * scale),
          bottomLeft: Radius.circular(4 * scale),
          bottomRight: Radius.circular(4 * scale),
        ),
      ),
      alignment: const Alignment(0, -.2),
      child: Container(
        height: 2 * scale,
        color: c.onAccent.withValues(alpha: .35),
      ),
    );
  }
}

class _ChestCard extends StatelessWidget {
  const _ChestCard({required this.chest, required this.onTap});

  final ClanChest chest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: l.clanChestTitle,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: c.accent.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.accent.withValues(alpha: .3)),
        ),
        child: Row(
          children: [
            const ChestGlyph(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.clanChestTitle,
                          style: NardType.bodyS.copyWith(
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                      ),
                      Text(
                        l.clanChestProgress(
                          formatAmount(chest.coins),
                          formatAmount(chest.target),
                        ),
                        style: NardType.bodyS.copyWith(
                          color: c.text.withValues(alpha: .7),
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  NardProgressBar(
                    value: chest.target == 0 ? 0 : chest.coins / chest.target,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 5.4 chat (or, with [activity], the system events only).
class ClanChatView extends ConsumerWidget {
  const ClanChatView({super.key, required this.detail, this.activity = false});

  final ClanDetail detail;
  final bool activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final chat = ref.watch(clanChatProvider(detail.id));
    final me = ref.watch(accountProvider).value?.id;
    final blocked = {
      for (final u in ref.watch(blocksProvider).value ?? const <PublicUser>[])
        u.id,
    };
    final muted = ref.watch(mutedPlayersProvider);
    final messages = [
      for (final m in chat.messages)
        if (activity ? m.system : true)
          if (m.author == null ||
              (!blocked.contains(m.author!.id) &&
                  !muted.contains(m.author!.id)))
            m,
    ];
    Widget list;
    if (chat.loading && messages.isEmpty) {
      list = Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    } else if (messages.isEmpty) {
      list = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            activity ? l.clanActivityEmpty : l.clanChatEmpty,
            textAlign: TextAlign.center,
            style: NardType.body.copyWith(color: c.textDim),
          ),
        ),
      );
    } else {
      final reversed = messages.reversed.toList();
      list = ListView.separated(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        itemCount: reversed.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final m = reversed[i];
          if (m.system) {
            final text = l.systemText(m);
            return text == null
                ? const SizedBox.shrink()
                : SystemMessagePill(text);
          }
          final author = m.author;
          final mine = author?.id == me;
          return ChatBubble(
            name: mine ? l.you : (author?.name ?? ''),
            text: m.text ?? '',
            mine: mine,
            onLongPress: () => _messageMenu(context, ref, m, mine: mine),
          );
        },
      );
    }
    if (activity) return list;
    return Column(
      children: [
        Expanded(child: list),
        ChatComposer(
          hint: l.clanChatHint,
          sendLabel: l.send,
          maxLength: ClanRules.chatMax,
          busy: chat.sending,
          notice: _mutedNotice(l, chat),
          onSend: (text) async {
            try {
              return await ref
                  .read(clanChatProvider(detail.id).notifier)
                  .send(text);
            } on Object catch (e) {
              if (context.mounted) showNote(context, clanErrorText(l, e));
              return false;
            }
          },
        ),
      ],
    );
  }

  /// Inline composer notice after a `403 muted` send (ADR-042).
  String? _mutedNotice(AppLocalizations l, ClanChatState chat) {
    if (!chat.mutedAt(DateTime.now())) return null;
    final until = chat.mutedUntil;
    return until == null
        ? l.clanChatMutedNoTime
        : l.clanChatMuted(formatModerationTime(until, l.localeName));
  }

  Future<void> _messageMenu(
    BuildContext context,
    WidgetRef ref,
    ClanMessage m, {
    required bool mine,
  }) async {
    final l = AppLocalizations.of(context);
    final author = m.author;
    final canDelete = ClanPermissions.canDeleteMessage(
      detail.myRole,
      own: mine,
    );
    if (author == null || (mine && !canDelete)) return;
    final choice = await showNardSheet<String>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GroupCard(
                children: [
                  if (!mine)
                    SheetActionRow(
                      icon: LucideIcons.user,
                      label: l.memberViewProfile,
                      onTap: () => Navigator.of(ctx).pop('menu'),
                    ),
                  if (!mine)
                    SheetActionRow(
                      icon: LucideIcons.flag,
                      label: l.playerMenuReport,
                      danger: true,
                      onTap: () => Navigator.of(ctx).pop('report'),
                    ),
                  if (canDelete)
                    SheetActionRow(
                      icon: LucideIcons.trash2,
                      label: l.chatDelete,
                      danger: true,
                      onTap: () => Navigator.of(ctx).pop('delete'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              NardButton(
                label: l.cancel,
                variant: NardButtonVariant.outline,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
    );
    if (choice == null || !context.mounted) return;
    final player = PlayerRef(id: author.id, name: author.name, inMyClan: true);
    switch (choice) {
      case 'menu':
        await showPlayerMenu(context, player);
      case 'report':
        unawaited(context.push('/report', extra: ReportArgs(player: player)));
      case 'delete':
        try {
          await ref.read(clanChatProvider(detail.id).notifier).delete(m.id);
        } on Object catch (e) {
          if (context.mounted) showNote(context, clanErrorText(l, e));
        }
    }
  }
}

/// Sandıq tab: weekly progress, fixed visible reward, donations.
class ClanChestView extends ConsumerStatefulWidget {
  const ClanChestView({super.key, required this.detail});

  final ClanDetail detail;

  static const presets = [100, 500, 1000, 2500];

  /// `config/clans.php` xp.chest_full.
  static const fullChestXp = 500;

  @override
  ConsumerState<ClanChestView> createState() => _ClanChestViewState();
}

class _ClanChestViewState extends ConsumerState<ClanChestView> {
  int? _busy;

  Future<void> _donate(int coins) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = coins);
    try {
      final (_, wallet) = await ref
          .read(apiClientProvider)
          .donate(widget.detail.id, coins, newIdempotencyKey());
      ref.read(inventoryProvider.notifier).setWallet(wallet);
      ref.invalidate(clanDetailProvider(widget.detail.id));
      if (mounted) showNote(context, l.clanDonated(formatAmount(coins)));
    } on Object catch (e) {
      if (mounted) showNote(context, clanErrorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final chest = widget.detail.chest ?? const ClanChest();
    final coins = ref.watch(inventoryProvider).value?.wallet.coins;
    final left = (chest.target - chest.coins).clamp(0, chest.target);
    final donors = [
      for (final m in widget.detail.members)
        if (m.weeklyDonated > 0) m,
    ]..sort((a, b) => b.weeklyDonated.compareTo(a.weeklyDonated));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(NardRadius.l),
            border: Border.all(color: c.accent.withValues(alpha: .3)),
          ),
          child: Column(
            children: [
              const ChestGlyph(scale: 1.6),
              const SizedBox(height: 12),
              Text(
                l.clanChestTitle,
                style: NardType.title.copyWith(color: c.text),
              ),
              const SizedBox(height: 6),
              Text(
                l.clanChestProgress(
                  formatAmount(chest.coins),
                  formatAmount(chest.target),
                ),
                style: NardType.labelL.copyWith(
                  color: c.accentHi,
                  fontFeatures: tabular,
                ),
              ),
              const SizedBox(height: 10),
              NardProgressBar(
                value: chest.target == 0 ? 0 : chest.coins / chest.target,
                height: 6,
              ),
              const SizedBox(height: 10),
              Text(
                chest.full
                    ? l.clanChestFullNote
                    : l.clanChestReward(ClanChestView.fullChestXp),
                textAlign: TextAlign.center,
                style: NardType.bodyS.copyWith(
                  color: c.text.withValues(alpha: .7),
                ),
              ),
              if (chest.myDonated != null) ...[
                const SizedBox(height: 4),
                Text(
                  l.clanChestMine(formatAmount(chest.myDonated!)),
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Overline(
            l.clanChestAmount,
            color: c.text.withValues(alpha: .6),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in ClanChestView.presets)
              _DonateChip(
                coins: p,
                busy: _busy == p,
                enabled:
                    !chest.full &&
                    _busy == null &&
                    p <= left &&
                    (coins == null || coins >= p),
                onTap: () => _donate(p),
              ),
          ],
        ),
        if (donors.isNotEmpty) ...[
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Overline(l.clanDonors, color: c.text.withValues(alpha: .6)),
          ),
          for (final m in donors)
            HairlineRow(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  PresenceAvatar(name: m.user.name, size: 30, ring: false),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        color: c.text,
                      ),
                    ),
                  ),
                  const CurrencyIcon(Currency.coins, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    formatAmount(m.weeklyDonated),
                    style: NardType.bodyS.copyWith(
                      color: c.text,
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _DonateChip extends StatelessWidget {
  const _DonateChip({
    required this.coins,
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final int coins;
  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Pressable(
      onTap: enabled ? onTap : null,
      semanticLabel: '${l.clanChestDonate} ${formatAmount(coins)}',
      child: AnimatedOpacity(
        duration: NardMotion.fast,
        opacity: enabled || busy ? 1 : .4,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NardRadius.m),
            border: Border.all(color: c.accent.withValues(alpha: .4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.accentHi,
                  ),
                )
              else
                const CurrencyIcon(Currency.coins, size: 16),
              const SizedBox(width: 8),
              Text(
                formatAmount(coins),
                style: NardType.labelM.copyWith(
                  fontSize: 14,
                  color: c.accentHi,
                  fontFeatures: tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
