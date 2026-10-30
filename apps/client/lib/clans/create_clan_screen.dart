import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/catalog.dart' show Currency;
import '../cosmetics/cosmetics_text.dart' show formatAmount;
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart';
import '../store/inventory.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart' show CurrencyIcon;
import '../ui/controls.dart';
import '../ui/fields.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_providers.dart';
import 'clan_rules.dart';
import 'clan_text.dart';
import 'emblem_builder_screen.dart';
import 'emblem_catalog.dart';

/// 19.1 / 19.2 Create clan in two steps: name, tag (availability check),
/// emblem; then join policy, minimum rating, language, description and
/// the 3 000-coin price (coins are earn-only: no buy path, ADR-022).
class CreateClanScreen extends ConsumerStatefulWidget {
  const CreateClanScreen({super.key});

  @override
  ConsumerState<CreateClanScreen> createState() => _CreateClanScreenState();
}

/// The tag field's availability state.
enum TagCheck { idle, checking, free, taken, invalid }

class _CreateClanScreenState extends ConsumerState<CreateClanScreen> {
  final _name = TextEditingController();
  final _tag = TextEditingController();
  final _description = TextEditingController();
  late ClanDraft _draft = ClanDraft(
    language: _appLanguage(),
    emblem: const Emblem(),
  );
  int _step = 1;
  TagCheck _tagCheck = TagCheck.idle;
  Timer? _tagTimer;
  bool _busy = false;
  String? _error;

  /// One key per attempt: a retried submit is not charged twice.
  final String _key = newIdempotencyKey();

  String _appLanguage() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return ClanRules.languages.contains(code) ? code : 'az';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_step == 1 && ClanRules.languages.contains(code)) {
      _draft = _draft.copyWith(language: code);
    }
  }

  @override
  void dispose() {
    _tagTimer?.cancel();
    _name.dispose();
    _tag.dispose();
    _description.dispose();
    super.dispose();
  }

  void _tagChanged(String raw) {
    final clean = ClanRules.cleanTag(raw);
    if (clean != raw) {
      _tag.value = TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(offset: clean.length),
      );
    }
    _draft = _draft.copyWith(tag: clean);
    _tagTimer?.cancel();
    if (clean.isEmpty) {
      setState(() => _tagCheck = TagCheck.idle);
      return;
    }
    if (!ClanRules.validTag(clean)) {
      setState(() => _tagCheck = TagCheck.invalid);
      return;
    }
    setState(() => _tagCheck = TagCheck.checking);
    _tagTimer = Timer(const Duration(milliseconds: 400), () => _check(clean));
  }

  Future<void> _check(String tag) async {
    try {
      final (valid, available) = await ref
          .read(apiClientProvider)
          .tagAvailable(tag);
      if (!mounted || _draft.tag != tag) return;
      setState(
        () =>
            _tagCheck =
                !valid
                    ? TagCheck.invalid
                    : available
                    ? TagCheck.free
                    : TagCheck.taken,
      );
    } on Object {
      if (mounted && _draft.tag == tag) {
        setState(() => _tagCheck = TagCheck.idle);
      }
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final draft = _draft.copyWith(
        name: ClanRules.normalizeName(_name.text),
        description: () => _description.text,
      );
      final (_, wallet) = await ref
          .read(apiClientProvider)
          .createClan(draft, _key);
      await refreshMembership(ref, wallet: wallet);
      if (mounted) context.go('/clan');
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = clanErrorText(l, e);
      });
      showNote(context, _error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 2) setState(() => _step = 1);
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l.createClanTitle,
                bare: true,
                onBack:
                    _step == 2
                        ? () => setState(() => _step = 1)
                        : () => Navigator.of(context).maybePop(),
                trailing: Text(
                  l.createStep(_step, 2),
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: .96,
                    color: c.accent,
                  ),
                ),
              ),
              Expanded(
                child: SocialGate(
                  builder:
                      (context, _) =>
                          _step == 1
                              ? _stepOne(context, l)
                              : _stepTwo(context, l),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepOne(BuildContext context, AppLocalizations l) {
    final c = context.nard;
    final nameLength = ClanRules.normalizeName(_name.text).characters.length;
    final nameOk = ClanRules.validName(_name.text);
    final (tagText, tagColor) = switch (_tagCheck) {
      TagCheck.free => (l.createTagFree, c.successText),
      TagCheck.taken => (l.createTagTaken, c.dangerText),
      TagCheck.invalid => (l.createTagInvalid, c.dangerText),
      _ => ('', c.textDim),
    };
    final can = ClanRules.canContinue(
      _draft.copyWith(name: _name.text),
      tagAvailable: _tagCheck == TagCheck.free,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ClanEmblem(
                    emblem: _draft.emblem,
                    width: 96,
                    initials:
                        _draft.emblem.symbol == 'initials'
                            ? clanInitials(_name.text)
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _Labeled(
                label: l.createNameLabel,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    NardTextField(
                      controller: _name,
                      height: 52,
                      maxLength: ClanRules.nameMax,
                      error: _name.text.isNotEmpty && !nameOk,
                      textCapitalization: TextCapitalization.words,
                      onChanged:
                          (v) =>
                              setState(() => _draft = _draft.copyWith(name: v)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        l.createNameCounter(nameLength, ClanRules.nameMax),
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.text.withValues(alpha: .5),
                          fontFeatures: tabular,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_name.text.isNotEmpty && !nameOk)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: Text(
                    l.createNameInvalid,
                    style: NardType.caption.copyWith(color: c.dangerText),
                  ),
                ),
              const SizedBox(height: 14),
              _Labeled(
                label: l.createTagLabel,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    NardTextField(
                      controller: _tag,
                      height: 52,
                      maxLength: ClanRules.tagMax,
                      error:
                          _tagCheck == TagCheck.taken ||
                          _tagCheck == TagCheck.invalid,
                      textCapitalization: TextCapitalization.characters,
                      style: NardType.mono.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                      ),
                      onChanged: _tagChanged,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child:
                          _tagCheck == TagCheck.checking
                              ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.accent,
                                ),
                              )
                              : Text(
                                tagText,
                                style: NardType.caption.copyWith(
                                  color: tagColor,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Overline(
                  l.createEmblemLabel,
                  color: c.text.withValues(alpha: .55),
                ),
              ),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final s in const [
                    'diamond',
                    'circle',
                    'diamond_dot',
                    'square',
                  ])
                    _SymbolTile(
                      symbol: s,
                      emblem: _draft.emblem,
                      label: l.symbolName(s),
                      onTap:
                          () => setState(
                            () =>
                                _draft = _draft.copyWith(
                                  emblem: _draft.emblem.copyWith(symbol: s),
                                ),
                          ),
                    ),
                  Pressable(
                    onTap: () async {
                      final e = await Navigator.of(context).push<Emblem>(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  EmblemBuilderScreen(initial: _draft.emblem),
                        ),
                      );
                      if (e != null && mounted) {
                        setState(() => _draft = _draft.copyWith(emblem: e));
                      }
                    },
                    semanticLabel: l.createEmblemMore,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.text.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: c.accent.withValues(alpha: .2),
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        l.createEmblemMore,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: NardType.micro.copyWith(color: c.accentHi),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Overline(
                  l.createColorLabel,
                  color: c.text.withValues(alpha: .55),
                ),
              ),
              ColorSwatches(
                size: 36,
                selected: _draft.emblem.color,
                onSelect:
                    (id) => setState(
                      () =>
                          _draft = _draft.copyWith(
                            emblem: _draft.emblem.copyWith(color: id),
                          ),
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: NardButton(
            label: l.continueAction,
            onPressed: can ? () => setState(() => _step = 2) : null,
          ),
        ),
      ],
    );
  }

  Widget _stepTwo(BuildContext context, AppLocalizations l) {
    final c = context.nard;
    final coins = ref.watch(inventoryProvider).value?.wallet.coins;
    final afford = coins == null || ClanRules.canAfford(coins);
    final min = _draft.minRating;
    final sliderValue =
        (min ?? ClanRules.ratingFloor - ClanRules.ratingStep).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Overline(
                  l.createPolicyLabel,
                  color: c.text.withValues(alpha: .55),
                ),
              ),
              GroupCard(
                children: [
                  for (final p in JoinPolicy.values)
                    Semantics(
                      selected: _draft.joinPolicy == p,
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap:
                            () => setState(
                              () => _draft = _draft.copyWith(joinPolicy: p),
                            ),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 14,
                          ),
                          color:
                              _draft.joinPolicy == p
                                  ? c.accent.withValues(alpha: .1)
                                  : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.policyName(p),
                                      style: NardType.labelM.copyWith(
                                        color: c.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l.policySub(p),
                                      style: NardType.caption.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: c.text.withValues(alpha: .6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              RadioDot(selected: _draft.joinPolicy == p),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 18, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Overline(
                        l.createMinRatingLabel,
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                    Text(
                      min == null ? l.createMinRatingAny : '$min',
                      style: NardType.labelM.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.text,
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ),
              ),
              RatingSlider(
                value: sliderValue,
                min: (ClanRules.ratingFloor - ClanRules.ratingStep).toDouble(),
                max: ClanRules.ratingMax.toDouble(),
                divisions:
                    (ClanRules.ratingMax -
                        ClanRules.ratingFloor +
                        ClanRules.ratingStep) ~/
                    ClanRules.ratingStep,
                startLabel: l.createMinRatingAny,
                endLabel: l.createMinRatingMax(ClanRules.ratingMax),
                semanticLabel: l.createMinRatingLabel,
                onChanged: (v) {
                  final r = v.round();
                  setState(
                    () =>
                        _draft = _draft.copyWith(
                          minRating: () => r < ClanRules.ratingFloor ? null : r,
                        ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Overline(
                  l.createLanguageLabel,
                  color: c.text.withValues(alpha: .55),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final code in ClanRules.languages)
                    NardChoiceChip(
                      label: l.languageName(code),
                      selected: _draft.language == code,
                      onTap:
                          () => setState(
                            () => _draft = _draft.copyWith(language: code),
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _Labeled(
                label: l.createDescriptionLabel,
                child: NardMultilineField(
                  controller: _description,
                  hint: '',
                  maxLength: ClanRules.descriptionMax,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    if (coins != null)
                      Text(
                        l.createBalance(
                          formatAmount(coins),
                          formatAmount(coins - ClanRules.createPrice),
                        ),
                        style: NardType.bodyS.copyWith(
                          color:
                              afford
                                  ? c.text.withValues(alpha: .65)
                                  : c.dangerText,
                          fontFeatures: tabular,
                        ),
                      ),
                    const Spacer(),
                    Flexible(
                      flex: 2,
                      child: Text(
                        l.createRenameNote(formatAmount(ClanRules.renamePrice)),
                        textAlign: TextAlign.right,
                        style: NardType.bodyS.copyWith(
                          color: c.text.withValues(alpha: .65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!afford)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: Text(
                    l.purchaseNotEnoughCoins,
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.dangerText,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              NardButton(
                label: l.createSubmit,
                onPressed: _busy || !afford ? null : _submit,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CurrencyIcon(Currency.coins, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      formatAmount(ClanRules.createPrice),
                      style: NardType.labelL.copyWith(
                        color:
                            _busy || !afford ? c.textFaintish : c.primaryText,
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
    );
  }
}

extension on NardColors {
  Color get textFaintish => text.withValues(alpha: .45);
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: NardType.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: c.text.withValues(alpha: .6),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _SymbolTile extends StatelessWidget {
  const _SymbolTile({
    required this.symbol,
    required this.emblem,
    required this.label,
    required this.onTap,
  });

  final String symbol;
  final Emblem emblem;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final selected = emblem.symbol == symbol;
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: NardMotion.fast,
          decoration: BoxDecoration(
            color:
                selected
                    ? EmblemCatalog.colorOf(emblem.color).$1
                    : c.text.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? c.accent : c.accent.withValues(alpha: .2),
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: EmblemPainter(
              emblem: Emblem(shape: 'circle', symbol: symbol),
              shape: false,
              accentHi:
                  selected
                      ? NardPalette.ivory100
                      : c.text.withValues(alpha: .6),
              text: c.text,
              dark: NardPalette.walnut900,
            ),
          ),
        ),
      ),
    );
  }
}
