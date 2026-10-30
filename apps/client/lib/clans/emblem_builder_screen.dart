import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_text.dart';
import 'emblem_catalog.dart';

/// 5.3 Emblem builder: Forma · Simvol · Rəng · Naxış over a large
/// preview; pops the chosen [Emblem] on "Saxla", null on "Ləğv et".
class EmblemBuilderScreen extends StatefulWidget {
  const EmblemBuilderScreen({super.key, this.initial = const Emblem()});

  final Emblem initial;

  @override
  State<EmblemBuilderScreen> createState() => _EmblemBuilderScreenState();
}

class _EmblemBuilderScreenState extends State<EmblemBuilderScreen> {
  late Emblem _emblem = widget.initial;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    Widget headerButton(
      String label,
      VoidCallback onTap, {
      bool strong = false,
    }) => Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          style: NardType.body.copyWith(
            fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
            color: strong ? c.accentHi : c.text.withValues(alpha: .7),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    headerButton(l.cancel, () => Navigator.of(context).pop()),
                    Expanded(
                      child: Text(
                        l.emblemTitle,
                        textAlign: TextAlign.center,
                        style: NardType.title.copyWith(
                          fontSize: 18,
                          color: c.text,
                        ),
                      ),
                    ),
                    headerButton(
                      l.emblemSave,
                      () => Navigator.of(context).pop(_emblem),
                      strong: true,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 280,
              decoration: BoxDecoration(gradient: c.emblemGlow),
              alignment: Alignment.center,
              child: ClanEmblem(
                emblem: _emblem,
                width: 170,
                initials:
                    _emblem.symbol == 'initials'
                        ? clanInitials(l.appName)
                        : null,
              ),
            ),
            UnderlineTabs(
              height: 42,
              labels: [
                l.emblemTabShape,
                l.emblemTabSymbol,
                l.emblemTabColor,
                l.emblemTabPattern,
              ],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  switch (_tab) {
                    0 => _grid([
                      for (final s in EmblemCatalog.shapes.keys)
                        _Tile(
                          label: l.shapeName(s),
                          selected: _emblem.shape == s,
                          onTap:
                              () => setState(
                                () => _emblem = _emblem.copyWith(shape: s),
                              ),
                          child: ClanEmblem(
                            emblem: Emblem(
                              shape: s,
                              color:
                                  _emblem.shape == s ? _emblem.color : 'slate',
                            ),
                            width: 42,
                            symbol: false,
                          ),
                        ),
                    ]),
                    1 => _grid([
                      for (final s in EmblemCatalog.symbols)
                        _Tile(
                          label: l.symbolName(s),
                          selected: _emblem.symbol == s,
                          onTap:
                              () => setState(
                                () => _emblem = _emblem.copyWith(symbol: s),
                              ),
                          child: ClanEmblem(
                            emblem: _emblem.copyWith(
                              symbol: s,
                              shape: 'circle',
                            ),
                            width: 44,
                            initials:
                                s == 'initials'
                                    ? clanInitials(l.appName)
                                    : null,
                          ),
                        ),
                    ]),
                    2 => const SizedBox.shrink(),
                    _ => _grid([
                      for (final p in EmblemCatalog.patterns)
                        _Tile(
                          label: l.patternName(p),
                          selected: _emblem.pattern == p,
                          onTap:
                              () => setState(
                                () => _emblem = _emblem.copyWith(pattern: p),
                              ),
                          child: ClanEmblem(
                            emblem: _emblem.copyWith(pattern: p),
                            width: 42,
                            symbol: false,
                          ),
                        ),
                    ]),
                  },
                  const SizedBox(height: 16),
                  Overline(
                    l.emblemPrimaryColor,
                    color: c.text.withValues(alpha: .6),
                  ),
                  const SizedBox(height: 10),
                  ColorSwatches(
                    selected: _emblem.color,
                    onSelect:
                        (id) => setState(
                          () => _emblem = _emblem.copyWith(color: id),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<Widget> tiles) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    children: tiles,
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: NardMotion.fast,
          decoration: BoxDecoration(
            color: c.tile,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? c.accent : c.lineSoft,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Opacity(opacity: selected ? 1 : .6, child: child),
        ),
      ),
    );
  }
}

/// Colour swatches (5.3 / 19.1): 38 Ø circles; selected = bg gap + 2px
/// `accentHi` ring.
class ColorSwatches extends StatelessWidget {
  const ColorSwatches({
    super.key,
    required this.selected,
    required this.onSelect,
    this.size = 38,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final id in EmblemCatalog.swatchOrder)
          Semantics(
            selected: id == selected,
            child: Pressable(
              onTap: () => onSelect(id),
              semanticLabel: l.colorName(id),
              minSize: size,
              child: Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(id == selected ? 4 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      id == selected
                          ? Border.all(color: c.accentHi, width: 2)
                          : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmblemCatalog.colorOf(id).$1,
                    border: Border.all(
                      color: NardPalette.ivory50.withValues(alpha: .15),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
