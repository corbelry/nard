import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_providers.dart';
import 'clan_text.dart';
import 'emblem_catalog.dart';

/// 5.2 Clan profile: hero, stats strip, requirements, top members and
/// the join / apply CTA for my state.
class ClanProfileScreen extends ConsumerStatefulWidget {
  const ClanProfileScreen({super.key, required this.clanId});

  final String clanId;

  @override
  ConsumerState<ClanProfileScreen> createState() => _ClanProfileScreenState();
}

class _ClanProfileScreenState extends ConsumerState<ClanProfileScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(clanDetailProvider(widget.clanId));
    } on Object catch (e) {
      if (mounted) showNote(context, clanErrorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() => _run(() async {
    final joined = await ref.read(apiClientProvider).joinClan(widget.clanId);
    if (joined) {
      await refreshMembership(ref);
      if (mounted) context.go('/clan');
    }
  });

  Future<void> _cancel() =>
      _run(() => ref.read(apiClientProvider).cancelClanRequest(widget.clanId));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final detail = ref.watch(clanDetailProvider(widget.clanId));
    final tint =
        detail.hasValue
            ? EmblemCatalog.colorOf(detail.requireValue.summary.emblem.color).$1
            : c.danger;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.clanProfileBg(tint)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(title: '', bare: true),
              Expanded(
                child: AsyncBody<ClanDetail>(
                  value: detail,
                  onRetry:
                      () => ref.invalidate(clanDetailProvider(widget.clanId)),
                  data: (d) => _body(context, l, d),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, ClanDetail d) {
    final c = context.nard;
    final s = d.summary;
    final account = ref.watch(accountProvider).value;
    final inOther = account?.clan != null && account!.clan!.id != d.id;
    Widget stat(String value, String label) => Expanded(
      child: Container(
        color: c.bg,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              style: NardType.labelL.copyWith(
                fontSize: 16,
                color: c.text,
                fontFeatures: tabular,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NardType.micro.copyWith(
                color: c.text.withValues(alpha: .6),
              ),
            ),
          ],
        ),
      ),
    );
    Widget req(String label, String value, {bool? met}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: NardType.body.copyWith(
                fontSize: 14,
                color: c.text.withValues(alpha: .7),
              ),
            ),
          ),
          Text(
            value,
            style: NardType.body.copyWith(
              fontSize: 14,
              color: c.text,
              fontFeatures: tabular,
            ),
          ),
          if (met != null) ...[
            const SizedBox(width: 6),
            Icon(
              met ? LucideIcons.check : LucideIcons.x,
              size: 14,
              color: met ? c.successText : c.dangerText,
            ),
          ],
        ],
      ),
    );
    final top = [...d.members]..sort(
      (a, b) => (b.user.bestRating ?? 0).compareTo(a.user.bestRating ?? 0),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  children: [
                    ClanEmblem(
                      emblem: s.emblem,
                      width: 96,
                      initials:
                          s.emblem.symbol == 'initials'
                              ? clanInitials(s.name)
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NardType.displayL.copyWith(
                              fontSize: 26,
                              color: c.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.clanTag(s.tag),
                          style: NardType.mono.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: c.accent,
                          ),
                        ),
                      ],
                    ),
                    if ((d.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        d.description!,
                        textAlign: TextAlign.center,
                        style: NardType.bodyS.copyWith(
                          height: 19 / 13,
                          color: c.text.withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: c.lineSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      stat('${s.level}', l.clanStatLevel),
                      const SizedBox(width: 1),
                      stat(
                        l.clanMembersValue(s.memberCount, s.maxMembers),
                        l.clanStatMembers,
                      ),
                      const SizedBox(width: 1),
                      stat(
                        s.rating == null ? l.valueNone : '${s.rating}',
                        l.clanStatRating,
                      ),
                      const SizedBox(width: 1),
                      stat(s.language.toUpperCase(), l.clanStatLanguage),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Overline(
                        l.clanRequirements,
                        color: c.text.withValues(alpha: .6),
                      ),
                    ),
                    req(
                      l.clanReqMinRating,
                      s.minRating == null ? l.clanReqNone : '${s.minRating}',
                      met:
                          s.minRating == null || d.myStatus == ClanStatus.member
                              ? null
                              : d.ratingMet,
                    ),
                    req(l.clanReqPolicy, l.policyName(s.joinPolicy)),
                  ],
                ),
              ),
              if (top.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Overline(
                          l.clanTopMembers,
                          color: c.text.withValues(alpha: .6),
                        ),
                      ),
                      for (final m in top.take(3))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              PresenceAvatar(name: m.user.name, size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l.clanMemberWithRole(
                                    m.user.name,
                                    l.roleName(m.role),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: NardType.body.copyWith(
                                    fontSize: 14,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              Text(
                                m.user.bestRating == null
                                    ? l.valueNone
                                    : '${m.user.bestRating}',
                                style: NardType.bodyS.copyWith(
                                  color: c.text.withValues(alpha: .7),
                                  fontFeatures: tabular,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _cta(context, l, d, inOther: inOther),
        ),
      ],
    );
  }

  Widget _cta(
    BuildContext context,
    AppLocalizations l,
    ClanDetail d, {
    required bool inOther,
  }) {
    final s = d.summary;
    NardButton disabled(String label) =>
        NardButton(label: label, onPressed: null);
    switch (d.myStatus) {
      case ClanStatus.member:
        return NardButton(
          label: l.clanOpenMine,
          variant: NardButtonVariant.outline,
          onPressed: () => context.go('/clan'),
        );
      case ClanStatus.pending:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            disabled(l.clanAppliedCta),
            const SizedBox(height: 8),
            Center(
              child: Pressable(
                onTap: _busy ? null : _cancel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    l.clanCancelApply,
                    style: NardType.bodyS.copyWith(color: context.nard.textDim),
                  ),
                ),
              ),
            ),
          ],
        );
      case ClanStatus.invited:
        return NardButton(
          label: l.clanAcceptInvite,
          onPressed: _busy || inOther ? null : _acceptInvite,
        );
      case ClanStatus.none:
        if (inOther) return disabled(l.clanLeaveFirst);
        if (s.full) return disabled(l.clanFullCta);
        if (s.joinPolicy == JoinPolicy.invite) {
          return disabled(l.clanInviteOnlyCta);
        }
        if (!d.ratingMet) return disabled(l.clanReqNotMet);
        return NardButton(
          label:
              s.joinPolicy == JoinPolicy.open ? l.clanJoinCta : l.clanApplyCta,
          onPressed: _busy ? null : _join,
        );
    }
  }

  Future<void> _acceptInvite() => _run(() async {
    final invites = await ref.read(apiClientProvider).clanInvites();
    final invite = invites.where((i) => i.clan.id == widget.clanId);
    if (invite.isEmpty) return;
    await ref.read(apiClientProvider).acceptClanInvite(invite.first.id);
    await refreshMembership(ref);
    if (mounted) context.go('/clan');
  });
}
