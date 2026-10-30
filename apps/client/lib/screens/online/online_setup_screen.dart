import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../online/online_draft.dart';
import '../../online/online_text.dart';
import '../../online/reachability.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/background.dart';
import '../../ui/buttons.dart';
import '../../ui/controls.dart';
import '../../ui/layout.dart';
import '../setup_screen.dart';

/// 2.2 Game setup, online mode (online.md §7.2): variant, format, time
/// control (Blits / Sürətli / Klassik; Gündəlik later, ADR-044) and the
/// Reytinqli toggle.
class OnlineSetupScreen extends ConsumerWidget {
  const OnlineSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final draft = ref.watch(onlineDraftProvider);
    final notifier = ref.read(onlineDraftProvider.notifier);
    final offline = ref.watch(offlineProvider);
    final account = ref.watch(accountProvider).value;
    final rating = ratingFor(account, draft.variant)?.rating;
    void edit({
      Variant? variant,
      int? length,
      QueueMode? mode,
      TimeControl? time,
    }) => notifier.set(
      draft.copyWith(
        variant: variant,
        matchLength: length,
        mode: mode,
        timeControl: time,
      ),
    );
    Widget timeTile(TimeControl t) => TimeTile(
      name: l.timeControlName(t),
      value: l.clockValue(t.clock),
      selected: draft.timeControl == t,
      onTap: () => edit(time: t),
    );
    final ranked = draft.mode == QueueMode.ranked;
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.setupOnlineTitle),
              OfflineBanner(text: l.offlineBanner, visible: offline),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  children: [
                    Overline(l.setupVariantLabel),
                    const SizedBox(height: 10),
                    NardSegmented<Variant>(
                      values: const [Variant.shortNard, Variant.longNard],
                      labels: [l.variantShort, l.variantLong],
                      selected: draft.variant,
                      onChanged: (v) => edit(variant: v),
                    ),
                    const SizedBox(height: 22),
                    Overline(l.setupFormatLabel),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final n in SetupScreen.formats) ...[
                          if (n != SetupScreen.formats.first)
                            const SizedBox(width: 8),
                          Expanded(
                            child: OptionTile(
                              label: l.formatName(n),
                              selected: draft.matchLength == n,
                              onTap: () => edit(length: n),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 22),
                    Overline(l.setupTimeLabel),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: timeTile(TimeControl.blitz)),
                        const SizedBox(width: 8),
                        Expanded(child: timeTile(TimeControl.rapid)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: timeTile(TimeControl.classic)),
                        const SizedBox(width: 8),
                        // Correspondence is a later product (QUESTIONS #20).
                        Expanded(
                          child: TimeTile(
                            name: l.timeDaily,
                            value: l.comingSoon,
                            selected: false,
                            onTap: null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: c.accent.withValues(alpha: .14),
                          ),
                          bottom: BorderSide(
                            color: c.accent.withValues(alpha: .1),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.setupRated,
                                  style: NardType.body.copyWith(color: c.text),
                                ),
                                if (rating != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    l.setupRatedSub(rating),
                                    style: NardType.caption.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: c.textDim,
                                      fontFeatures: tabular,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          NardSwitch(
                            value: ranked,
                            semanticLabel: l.setupRated,
                            onChanged:
                                (v) => edit(
                                  mode: v ? QueueMode.ranked : QueueMode.casual,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: NardButton(
                  label: l.setupFindOpponent,
                  onPressed:
                      offline ? null : () => startSearch(context, ref, draft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
