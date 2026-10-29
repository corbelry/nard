import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_core/nard_core.dart';

import '../app/setup_draft.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';

/// 2.2 Game setup (vs computer): variant, match length, cube.
class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  static const formats = [1, 3, 5, 7];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final setup = ref.watch(setupDraftProvider);
    final draft = ref.read(setupDraftProvider.notifier);
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.setupTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  children: [
                    Overline(l.setupVariantLabel),
                    const SizedBox(height: 10),
                    NardSegmented<Variant>(
                      values: const [Variant.shortNard, Variant.longNard],
                      labels: [l.variantShort, l.variantLong],
                      selected: setup.variant,
                      onChanged:
                          (v) => draft.edit((s) => s.copyWith(variant: v)),
                    ),
                    const SizedBox(height: 22),
                    Overline(l.setupFormatLabel),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final n in formats) ...[
                          if (n != formats.first) const SizedBox(width: 8),
                          Expanded(
                            child: OptionTile(
                              label:
                                  n == 1 ? l.formatOneGame : l.formatPoints(n),
                              selected: setup.matchLength == n,
                              onTap:
                                  () => draft.edit(
                                    (s) => s.copyWith(matchLength: n),
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (setup.variant == Variant.shortNard) ...[
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
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.setupCube,
                                style: NardType.body.copyWith(color: c.text),
                              ),
                            ),
                            NardSwitch(
                              value: setup.cube,
                              semanticLabel: l.setupCube,
                              onChanged:
                                  (v) => draft.edit((s) => s.copyWith(cube: v)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: NardButton(
                  label: l.continueAction,
                  onPressed: () => context.push('/ai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
