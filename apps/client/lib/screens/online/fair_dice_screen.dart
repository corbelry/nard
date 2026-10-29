import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../online/fair_check.dart';
import '../../online/online_game_controller.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/background.dart';
import '../../ui/buttons.dart';
import '../../ui/extra_tokens.dart';
import '../../ui/layout.dart';
import '../../ui/pressable.dart';

/// 10.3 Fair dice: the commit–reveal data of the current (or just
/// finished) online game and every roll recomputed with `FairDice`.
class FairDiceScreen extends ConsumerStatefulWidget {
  const FairDiceScreen({super.key});

  @override
  ConsumerState<FairDiceScreen> createState() => _FairDiceScreenState();
}

class _FairDiceScreenState extends ConsumerState<FairDiceScreen> {
  /// Selected roll number; null = the latest.
  int? _selected;

  Future<void> _pick(FairCheck check) async {
    final l = AppLocalizations.of(context);
    final picked = await showNardSheet<int>(
      context,
      builder: (ctx) {
        final c = ctx.nard;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.fairPickTitle),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final r in check.rolls.reversed)
                    Pressable(
                      onTap: () => Navigator.of(ctx).pop(r.n),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: c.accent.withValues(alpha: .08),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                [
                                  l.fairRollRow(
                                    r.n,
                                    r.recorded.die1,
                                    r.recorded.die2,
                                  ),
                                  if (r.opening) l.fairOpeningTag,
                                ].join(' · '),
                                style: NardType.body.copyWith(
                                  color: c.text,
                                  fontFeatures: tabular,
                                ),
                              ),
                            ),
                            if (r.verifiable)
                              Icon(
                                r.matches ? LucideIcons.check : LucideIcons.x,
                                size: 16,
                                color: r.matches ? c.successText : c.dangerText,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (picked != null && mounted) setState(() => _selected = picked);
  }

  String _copyText(
    AppLocalizations l,
    FairCheck check,
    String? mine,
    String? theirs,
    RollCheck? roll,
  ) => [
    '${l.fairCommitment}: ${check.commitment}',
    '${l.fairServerSeed}: ${check.serverSeed ?? l.fairPending}',
    '${l.fairYourSeed}: ${mine ?? l.valueNone}',
    '${l.fairOpponentSeed}: ${theirs ?? l.valueNone}',
    if (roll != null)
      '${l.fairRollNumber}: ${l.fairRollRow(roll.n, roll.recorded.die1, roll.recorded.die2)}',
  ].join('\n');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final view = ref.watch(onlineGameProvider);
    final online = view?.online;
    final me = view?.session.setup.localSide ?? Side.white;
    final check =
        view == null || online == null
            ? null
            : checkRolls(
              record: view.session.record,
              commitment: online.commitment,
              serverSeed: online.serverSeed,
              clientSeeds: online.clientSeeds,
            );
    final rolls = check?.rolls ?? const <RollCheck>[];
    final roll =
        rolls.isEmpty
            ? null
            : rolls[min(_selected ?? rolls.length - 1, rolls.length - 1)];
    final mine = online?.clientSeeds[me];
    final theirs = online?.clientSeeds[me.opponent];
    final bottom = MediaQuery.paddingOf(context).bottom;

    final steps = <(String, String?)>[
      if (check != null)
        (l.fairCommitment, l.fairCommitmentValue(check.commitment)),
      (l.fairServerSeed, check?.serverSeed),
      (l.fairYourSeed, mine),
      (l.fairOpponentSeed, theirs),
      (
        l.fairRollNumber,
        roll == null
            ? null
            : roll.computed != null
            ? l.fairRollValue(roll.n, roll.computed!.die1, roll.computed!.die2)
            : l.fairRollRow(roll.n, roll.recorded.die1, roll.recorded.die2),
      ),
    ];

    Widget result;
    if (check == null || roll == null) {
      result = _ResultCard.note(l.fairNoRolls);
    } else if (!check.revealed || !roll.verifiable) {
      result = _ResultCard.note(l.fairPendingNote);
    } else if (check.commitmentOk != true) {
      result = _ResultCard(
        ok: false,
        title: l.fairCommitmentMismatch,
        sub: l.fairCommitmentValue(check.commitment),
      );
    } else {
      final d = roll.recorded;
      result = _ResultCard(
        ok: roll.matches,
        title:
            roll.matches
                ? l.fairMatch(d.die1, d.die2)
                : l.fairMismatch(d.die1, d.die2),
        sub: roll.matches ? l.fairMatchSub(roll.n) : l.fairMismatchSub(roll.n),
      );
    }

    return Scaffold(
      body: NardBackground(
        band: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.fairTitle, bare: true),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  children: [
                    Text(
                      l.fairIntro,
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        height: 21 / 14,
                        color: c.text.withValues(alpha: .75),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < steps.length; i++) ...[
                      _Step(
                        number: i + 1,
                        label: steps[i].$1,
                        value: steps[i].$2,
                        pending: i == 1 ? l.fairPending : l.valueNone,
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                    result,
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, max(40, bottom + 6)),
                child: Row(
                  children: [
                    Expanded(
                      child: NardButton(
                        label: l.fairCopy,
                        variant: NardButtonVariant.outline,
                        height: 52,
                        labelStyle: NardType.labelM.copyWith(fontSize: 14),
                        onPressed:
                            check == null
                                ? null
                                : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: _copyText(
                                        l,
                                        check,
                                        mine,
                                        theirs,
                                        roll,
                                      ),
                                    ),
                                  );
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(l.copied)),
                                  );
                                },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NardButton(
                        label: l.fairCheckAnother,
                        variant: NardButtonVariant.accent,
                        height: 52,
                        labelStyle: NardType.labelM.copyWith(fontSize: 14),
                        onPressed:
                            check == null || rolls.length < 2
                                ? null
                                : () => _pick(check),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.value,
    required this.pending,
  });

  final int number;
  final String label;
  final String? value;
  final String pending;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final style = NardType.mono.copyWith(
      fontSize: 11,
      height: 1.5,
      color: c.text.withValues(alpha: value == null ? .45 : .7),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.selectedFill,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: NardType.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: c.accentHi,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: NardType.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: c.codeBox,
                  borderRadius: BorderRadius.circular(NardRadius.s),
                ),
                child: SelectableText(value ?? pending, style: style),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.ok, required this.title, this.sub})
    : note = false;

  const _ResultCard.note(this.title) : ok = true, sub = null, note = true;

  final bool ok;
  final String title;
  final String? sub;
  final bool note;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    if (note) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.tile,
          borderRadius: BorderRadius.circular(c.cardRadius),
          border: Border.all(color: c.lineSoft),
        ),
        child: Text(title, style: NardType.bodyS.copyWith(color: c.textDim)),
      );
    }
    final (fill, ring, disc, fg) =
        ok
            ? (
              c.success.withValues(alpha: .16),
              c.successText.withValues(alpha: .4),
              c.success,
              c.successText,
            )
            : (
              c.danger.withValues(alpha: .16),
              c.dangerText.withValues(alpha: .4),
              c.danger,
              c.dangerText,
            );
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(c.cardRadius),
          border: Border.all(color: ring),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: disc),
              child: Icon(
                ok ? LucideIcons.check : LucideIcons.x,
                size: 16,
                color: c.text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NardType.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      style: NardType.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: c.text.withValues(alpha: .65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
