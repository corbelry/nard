import 'package:flutter/widgets.dart';
import 'package:nard_protocol/nard_protocol.dart' show TimeControl;

import '../l10n/gen/app_localizations.dart';
import '../online/online_text.dart';
import '../theme/nard_tokens.dart';
import 'controls.dart';

/// The 2×2 time-control tiles (screens.md "Time tile", ADR-044): Blits /
/// Sürətli / Klassik selectable, Gündəlik disabled with "Tezliklə"
/// (correspondence is a later product, QUESTIONS #20). Used by 2.2 and the
/// 6.3 room's "Vaxt" picker.
class TimeControlTiles extends StatelessWidget {
  const TimeControlTiles({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final TimeControl selected;
  final ValueChanged<TimeControl> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget tile(TimeControl t) => Expanded(
      child: TimeTile(
        name: l.timeControlName(t),
        value: l.clockValue(t.clock),
        selected: selected == t,
        onTap: () => onSelect(t),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            tile(TimeControl.blitz),
            const SizedBox(width: NardSpace.s2),
            tile(TimeControl.rapid),
          ],
        ),
        const SizedBox(height: NardSpace.s2),
        Row(
          children: [
            tile(TimeControl.classic),
            const SizedBox(width: NardSpace.s2),
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
      ],
    );
  }
}
