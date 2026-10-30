import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/catalog.dart' show Currency;
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../store/inventory.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/social.dart';
import 'tournament_models.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// 21.1 Sit-and-go waiting lobby: size chips, counter, seats, table info
/// and join / leave (refund). Polls every 5 s; a full table opens the
/// bracket, an unfilled one 21.4.
class SngScreen extends ConsumerStatefulWidget {
  const SngScreen({super.key, this.size});

  final int? size;

  @override
  ConsumerState<SngScreen> createState() => _SngScreenState();
}

class _SngScreenState extends ConsumerState<SngScreen> {
  late int _size = widget.size ?? 16;
  Timer? _poll;
  bool _busy = false;
  String _key = newIdempotencyKey();

  /// The table I sit at, followed through the detail once it leaves the
  /// open list (started or cancelled).
  String? _myTable;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _poll = pollEvery(const Duration(seconds: 5), _refresh);
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(sngTablesProvider);
    final id = _myTable;
    if (id == null || _gone) return;
    try {
      final d = await ref.read(apiClientProvider).tournament(id);
      if (mounted) _follow(d.tournament);
    } on Object {
      // Next poll.
    }
  }

  void _follow(Tournament t) {
    if (_gone) return;
    if (t.status == TournamentStatus.running ||
        t.status == TournamentStatus.finished) {
      _gone = true;
      ref.read(tournamentSocketProvider.notifier).connect();
      context.pushReplacement('/tournaments/${t.id}/bracket');
    } else if (t.status == TournamentStatus.cancelled) {
      _gone = true;
      ref.read(inventoryProvider.notifier).refresh();
      context.pushReplacement('/tournaments/notfilled', extra: t);
    }
  }

  Future<void> _join() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final (t, wallet) = await ref
          .read(apiClientProvider)
          .joinSng(_size, _key);
      ref.read(inventoryProvider.notifier).setWallet(wallet);
      _myTable = t.id;
      ref.invalidate(sngTablesProvider);
      if (mounted) _follow(t);
    } on Object catch (e) {
      if (mounted) showNote(context, tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave(String id) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final (_, wallet) = await ref
          .read(apiClientProvider)
          .unregisterTournament(id);
      ref.read(inventoryProvider.notifier).setWallet(wallet);
      _myTable = null;
      _key = newIdempotencyKey();
      ref.invalidate(sngTablesProvider);
      if (mounted) {
        context.canPop() ? context.pop() : context.go('/tournaments');
      }
    } on Object catch (e) {
      if (mounted) showNote(context, tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final tables = ref.watch(sngTablesProvider);
    final mine = tables.value?.where((t) => t.registered).firstOrNull;
    if (mine != null) {
      _myTable ??= mine.tournamentId;
      if (_size != mine.size) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _size = mine.size);
        });
      }
    }
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.sngTitle(_size), bare: true),
              Expanded(
                child: AsyncBody<List<SngTable>>(
                  value: tables,
                  onRetry: () => ref.invalidate(sngTablesProvider),
                  data: (list) => _body(context, l, c, list, mine),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l,
    NardColors c,
    List<SngTable> list,
    SngTable? mine,
  ) {
    final table =
        list.where((t) => t.size == _size).firstOrNull ??
        SngTable(
          size: _size,
          variant: list.firstOrNull?.variant ?? variantFromApi('shortNard'),
          matchLength: 3,
          entryCoins: 500,
          prizeFund: _size * 450,
        );
    final registered = mine != null && mine.size == _size;
    final joined = table.joined;
    final account = ref.watch(accountProvider).value;
    final wallet = ref.watch(inventoryProvider).value?.wallet;
    final poor = wallet != null && wallet.coins < table.entryCoins;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            children: [
              IgnorePointer(
                ignoring: mine != null,
                child: EqualChips<int>(
                  values: const [8, 16, 32],
                  labels: [l.sngSize(8), l.sngSize(16), l.sngSize(32)],
                  selected: _size,
                  onChanged: (v) => setState(() => _size = v),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$joined',
                        style: NardType.displayXl.copyWith(
                          fontSize: 48,
                          height: 1,
                          color: c.text,
                          fontFeatures: tabular,
                        ),
                      ),
                      TextSpan(
                        text: ' / $_size',
                        style: NardType.displayXl.copyWith(
                          fontSize: 48,
                          height: 1,
                          color: c.text.withValues(alpha: .4),
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.sngStartsWhenFull,
                textAlign: TextAlign.center,
                style: NardType.bodyS.copyWith(
                  color: c.text.withValues(alpha: .65),
                ),
              ),
              const SizedBox(height: 16),
              _SeatGrid(
                size: _size,
                taken: joined,
                me: registered ? account?.name : null,
              ),
              const SizedBox(height: 16),
              GroupCard(
                children: [
                  InfoRow(
                    label: l.roomSettingFormat,
                    value: l.sngFormatValue(
                      variantName(l, table.variant),
                      table.matchLength,
                    ),
                  ),
                  InfoRow(
                    label: l.sngEntryFee,
                    value: priceText(l, Currency.coins, table.entryCoins),
                  ),
                  InfoRow(
                    label: l.tourPrizeFund,
                    value: priceText(l, Currency.coins, table.prizeFund),
                  ),
                  InfoRow(
                    label: l.sngTimeControl,
                    value: l.timeValue(
                      table.clockReserveMs ~/ 60000,
                      table.clockDelayMs ~/ 1000,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${l.sngNoShowRule(60)} ${l.sngExpires(10)}.',
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
          padding: EdgeInsets.fromLTRB(16, 16, 16, max(24, bottom + 8)),
          child:
              _busy
                  ? SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: c.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : registered
                  ? NardButton(
                    label: l.sngLeave,
                    variant: NardButtonVariant.outline,
                    onPressed: () {
                      final id = mine.tournamentId;
                      if (id != null) unawaited(_leave(id));
                    },
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NardButton(
                        label: l.sngJoin,
                        trailing: PriceTag(
                          currency: Currency.coins,
                          amount: table.entryCoins,
                          color: poor ? null : c.primaryText,
                          fontSize: 16,
                        ),
                        onPressed:
                            poor || mine != null || account == null
                                ? null
                                : _join,
                      ),
                      if (poor) ...[
                        const SizedBox(height: 10),
                        Text(
                          l.purchaseNotEnoughCoins,
                          textAlign: TextAlign.center,
                          style: NardType.bodyS.copyWith(
                            color: c.text.withValues(alpha: .7),
                          ),
                        ),
                      ],
                    ],
                  ),
        ),
      ],
    );
  }
}

/// 21.1 seats: 8 columns of circles; taken (initials hidden), mine, empty.
class _SeatGrid extends StatelessWidget {
  const _SeatGrid({required this.size, required this.taken, this.me});

  final int size;
  final int taken;
  final String? me;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return LayoutBuilder(
      builder: (context, box) {
        final cell = (box.maxWidth - 7 * 8) / 8;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < size; i++)
              AnimatedContainer(
                duration: NardMotion.fast,
                width: cell,
                height: cell,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < taken ? c.text.withValues(alpha: .08) : null,
                  gradient:
                      me != null && i == 0
                          ? LinearGradient(
                            begin: const Alignment(-.5, -.87),
                            end: const Alignment(.5, .87),
                            colors: c.avatarMe,
                          )
                          : null,
                  border: Border.all(
                    color:
                        me != null && i == 0
                            ? c.accent
                            : i < taken
                            ? c.accent.withValues(alpha: .3)
                            : c.text.withValues(alpha: .14),
                    width: me != null && i == 0 ? 1.5 : 1,
                  ),
                ),
                child:
                    me != null && i == 0
                        ? Text(
                          me!.isEmpty ? '?' : me!.characters.first,
                          style: NardType.title.copyWith(
                            fontSize: 13,
                            color: c.text,
                          ),
                        )
                        : null,
              ),
          ],
        );
      },
    );
  }
}
