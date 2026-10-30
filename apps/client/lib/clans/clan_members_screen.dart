import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/online_draft.dart';
import '../social/friends_screen.dart' show presenceDot, presenceText;
import '../social/player_menu.dart';
import '../social/social_gate.dart';
import '../social/social_models.dart';
import '../social/social_providers.dart';
import '../social/social_socket.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_providers.dart';
import 'clan_rules.dart';
import 'clan_text.dart';

/// 5.5 Members & management: role first, then rating; tapping a member
/// opens the action sheet with what my role allows (ADR-036).
class ClanMembersScreen extends ConsumerStatefulWidget {
  const ClanMembersScreen({super.key, required this.clanId});

  final String clanId;

  @override
  ConsumerState<ClanMembersScreen> createState() => _ClanMembersScreenState();
}

class _ClanMembersScreenState extends ConsumerState<ClanMembersScreen> {
  String? _open;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _queryPresence());
  }

  void _queryPresence() {
    final d = ref.read(clanDetailProvider(widget.clanId)).value;
    if (d == null || !mounted) return;
    ref.read(socialSocketProvider.notifier).queryPresence([
      for (final m in d.members) m.user.id,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    ref.listen(clanDetailProvider(widget.clanId), (_, next) {
      if (next.hasValue) _queryPresence();
    });
    final detail = ref.watch(clanDetailProvider(widget.clanId));
    final s = detail.value?.summary;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenHeader(title: '', bare: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      l.membersTitle,
                      style: NardType.title.copyWith(
                        fontSize: 22,
                        color: c.text,
                      ),
                    ),
                  ),
                  if (s != null)
                    Text(
                      l.membersCount(s.memberCount, s.maxMembers),
                      style: NardType.bodyS.copyWith(
                        color: c.text.withValues(alpha: .6),
                        fontFeatures: tabular,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AsyncBody<ClanDetail>(
                value: detail,
                onRetry:
                    () => ref.invalidate(clanDetailProvider(widget.clanId)),
                data: (d) => _list(context, l, d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations l, ClanDetail d) {
    final c = context.nard;
    final me = ref.watch(accountProvider).value?.id;
    final matches = ref.watch(presenceProvider);
    final members = [...d.members]..sort((a, b) {
      final r = b.role.index - a.role.index;
      if (r != 0) return r;
      return (b.user.bestRating ?? 0).compareTo(a.user.bestRating ?? 0);
    });
    return RefreshIndicator(
      color: c.accent,
      onRefresh: () async => ref.invalidate(clanDetailProvider(widget.clanId)),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final m in members)
            HairlineRow(
              height: 58,
              highlighted: _open == m.user.id,
              semanticLabel: m.user.name,
              onTap: m.user.id == me ? null : () => _actions(context, d, m),
              child: Row(
                children: [
                  PresenceAvatar(
                    name: m.user.name,
                    size: 36,
                    ring: false,
                    me: m.user.id == me,
                    ringBg: c.bg,
                    presence: presenceDot(presenceOf(m.user, matches)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.user.id == me
                              ? l.memberMe(m.user.name)
                              : m.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.memberMeta(
                            presenceText(l, presenceOf(m.user, matches)),
                            m.user.bestRating == null
                                ? l.valueNone
                                : '${m.user.bestRating}',
                          ),
                          maxLines: 1,
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.text.withValues(alpha: .6),
                            fontFeatures: tabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RoleBadge(role: m.role, label: l.roleName(m.role)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _actions(
    BuildContext context,
    ClanDetail d,
    ClanMember m,
  ) async {
    final l = AppLocalizations.of(context);
    final actor = d.myRole;
    final roles = ClanPermissions.assignableRoles(actor, m.role);
    setState(() => _open = m.user.id);
    final choice = await showNardSheet<String>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l.clanMemberWithRole(m.user.name, l.roleName(m.role)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.title.copyWith(
                    fontSize: 18,
                    color: ctx.nard.text,
                  ),
                ),
              ),
              SheetActionRow(
                label: l.memberViewProfile,
                onTap: () => Navigator.of(ctx).pop('profile'),
              ),
              SheetActionRow(
                label: l.memberInviteFriendly,
                onTap: () => Navigator.of(ctx).pop('invite'),
              ),
              for (final r in roles)
                SheetActionRow(
                  label: switch (r) {
                    ClanRole.coLeader => l.memberPromoteCoLeader,
                    ClanRole.elder => l.memberPromoteElder,
                    _ => l.memberDemote,
                  },
                  accent: true,
                  onTap: () => Navigator.of(ctx).pop('role:${r.api}'),
                ),
              if (ClanPermissions.canTransfer(actor))
                SheetActionRow(
                  label: l.memberTransferLead,
                  accent: true,
                  onTap: () => Navigator.of(ctx).pop('leader'),
                ),
              if (ClanPermissions.canKick(actor, m.role))
                SheetActionRow(
                  label: l.memberKick,
                  danger: true,
                  onTap: () => Navigator.of(ctx).pop('kick'),
                ),
            ],
          ),
    );
    if (mounted) setState(() => _open = null);
    if (choice == null || !context.mounted) return;
    final api = ref.read(apiClientProvider);
    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
        ref.invalidate(clanDetailProvider(d.id));
      } on Object catch (e) {
        if (context.mounted) showNote(context, clanErrorText(l, e));
      }
    }

    switch (choice) {
      case 'profile':
        await showPlayerMenu(context, PlayerRef.of(m.user, inMyClan: true));
      case 'invite':
        final draft = ref.read(onlineDraftProvider);
        ref
            .read(socialSocketProvider.notifier)
            .createRoom(
              draft.variant,
              max(1, draft.matchLength),
              invite: m.user,
              timeControl: draft.timeControl,
            );
        unawaited(context.push('/room'));
      case 'leader':
        final ok = await _confirm(
          context,
          l.memberTransferConfirm(m.user.name),
          l.memberTransferBody,
          l.memberTransferLead,
          danger: false,
        );
        if (ok) {
          await run(() => api.setClanRole(d.id, m.user.id, ClanRole.leader));
          await refreshMembership(ref);
        }
      case 'kick':
        final ok = await _confirm(
          context,
          l.memberKickConfirm(m.user.name),
          null,
          l.memberKick,
          danger: true,
        );
        if (ok) await run(() => api.kickMember(d.id, m.user.id));
      default:
        if (choice.startsWith('role:')) {
          final role = ClanRole.parse(choice.substring(5));
          await run(() => api.setClanRole(d.id, m.user.id, role));
        }
    }
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String? body,
    String action, {
    required bool danger,
  }) async {
    final l = AppLocalizations.of(context);
    final ok = await showNardSheet<bool>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(title),
              if (body != null) ...[
                const SizedBox(height: 8),
                Text(
                  body,
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    color: ctx.nard.text.withValues(alpha: .8),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              NardButton(
                label: action,
                variant:
                    danger
                        ? NardButtonVariant.danger
                        : NardButtonVariant.primary,
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
    return ok == true;
  }
}

/// Join requests (leaders/elders; not designed): accept / decline.
class ClanRequestsScreen extends ConsumerWidget {
  const ClanRequestsScreen({super.key, required this.clanId});

  final String clanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final role = ref.watch(clanDetailProvider(clanId)).value?.myRole;
    Future<void> act(Future<void> Function() action) async {
      try {
        await action();
        ref
          ..invalidate(clanRequestsProvider(clanId))
          ..invalidate(clanDetailProvider(clanId));
      } on Object catch (e) {
        if (context.mounted) showNote(context, clanErrorText(l, e));
      }
    }

    final api = ref.read(apiClientProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.clanMenuRequests, bare: true),
            Expanded(
              child: AsyncBody<List<JoinRequest>>(
                value: ref.watch(clanRequestsProvider(clanId)),
                onRetry: () => ref.invalidate(clanRequestsProvider(clanId)),
                data: (requests) {
                  if (requests.isEmpty) {
                    return MessageState(title: l.requestsEmpty, body: '');
                  }
                  return ListView(
                    children: [
                      for (final r in requests)
                        HairlineRow(
                          height: 64,
                          child: Row(
                            children: [
                              PresenceAvatar(name: r.user.name, size: 42),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  r.user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: NardType.labelM.copyWith(
                                    color: c.text,
                                  ),
                                ),
                              ),
                              SmallActionButton(
                                label: l.friendAccept,
                                onTap:
                                    ClanPermissions.canAcceptRequest(role)
                                        ? () => act(
                                          () => api.acceptClanRequest(
                                            clanId,
                                            r.id,
                                          ),
                                        )
                                        : null,
                              ),
                              if (ClanPermissions.canDeclineRequest(role))
                                Pressable(
                                  onTap:
                                      () => act(
                                        () => api.declineClanRequest(
                                          clanId,
                                          r.id,
                                        ),
                                      ),
                                  semanticLabel: l.friendDismiss,
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 18,
                                    color: c.text.withValues(alpha: .6),
                                  ),
                                ),
                            ],
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
