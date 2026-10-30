import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_client/analysis/analysis_engine.dart';
import 'package:nard_client/analysis/analysis_widgets.dart';
import 'package:nard_client/app/router.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/puzzles/puzzle_input.dart';
import 'package:nard_client/puzzles/puzzle_models.dart';
import 'package:nard_client/puzzles/puzzle_screen.dart';
import 'package:nard_client/screens/replay_screen.dart';
import 'package:nard_client/seasons/leaderboard_screen.dart';
import 'package:nard_client/seasons/season_models.dart';
import 'package:nard_client/seasons/season_pass_screen.dart';
import 'package:nard_client/seasons/season_providers.dart';
import 'package:nard_client/seasons/season_summary_screen.dart';
import 'package:nard_client/store/inventory.dart';
import 'package:nard_client/store/store_models.dart';
import 'package:nard_client/tournaments/bracket_layout.dart';
import 'package:nard_client/tournaments/bracket_screen.dart';
import 'package:nard_client/tournaments/private_tournament_screen.dart';
import 'package:nard_client/tournaments/sng_screen.dart';
import 'package:nard_client/tournaments/standings_screen.dart';
import 'package:nard_client/tournaments/tournament_detail_screen.dart';
import 'package:nard_client/tournaments/tournament_list_screen.dart';
import 'package:nard_client/tournaments/tournament_models.dart';
import 'package:nard_client/tournaments/tournament_outcomes.dart';
import 'package:nard_client/tournaments/tournament_text.dart';
import 'package:nard_client/ui/layout.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import 'phase6_fakes.dart';
import 'store_fakes.dart';

/// A short Short Nard game played by a seeded bot (deterministic).
GameRecord shortGame({int turns = 6}) {
  const rules = ShortNardRules();
  var state = GameState.newGame(rules);
  var record = GameRecord(variant: Variant.shortNard, config: state.config);
  final dice = Random(3);
  final bot = HeuristicBot(BotLevel.easy, random: Random(5));
  void act(GameAction a) {
    state = state.apply(a);
    record = record.add(a);
  }

  act(OpeningRoll(5, 2));
  for (var t = 0; t < turns; t++) {
    if (state.phase == GamePhase.awaitingRoll) {
      act(
        RollDice(
          state.turn,
          DiceRoll(dice.nextInt(6) + 1, dice.nextInt(6) + 1),
        ),
      );
    }
    final turn = bot.chooseTurn(rules, state.board, state.dice!);
    act(PlayTurn(state.turn, turn.moves));
  }
  return record;
}

Future<ProviderContainer> _container(FakeApi api) async {
  final container = ProviderContainer(overrides: phase6Overrides(api));
  addTearDown(container.dispose);
  container
    ..listen(inventoryProvider, (_, _) {})
    ..listen(seasonProvider, (_, _) {});
  await container.read(accountProvider.future);
  await container.read(inventoryProvider.future);
  return container;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  group('tournament models and text', () {
    test('summary JSON parses (contract shapes)', () {
      final t = Tournament.fromJson(
        tournamentJson(type: 'round_robin', kind: 'sit_and_go'),
      );
      expect(t.type, TournamentType.roundRobin);
      expect(t.kind, TournamentKind.sitAndGo);
      expect(t.paid, isTrue);
      expect(t.entryCoins, 500);
      expect(t.prizes.first.items, ['title.regular']);
      expect(t.prizes.last.from, 3);
      expect(t.prizes.last.to, 4);
    });

    test('Azerbaijani ordinals follow vowel harmony (§19.29)', () {
      expect(
        [
          1,
          2,
          3,
          4,
          5,
          6,
          9,
          10,
          16,
          20,
          30,
          40,
          100,
        ].map((n) => ordinal('az', n)),
        [
          '1-ci',
          '2-ci',
          '3-cü',
          '4-cü',
          '5-ci',
          '6-cı',
          '9-cu',
          '10-cu',
          '16-cı',
          '20-ci',
          '30-cu',
          '40-cı',
          '100-cü',
        ],
      );
      expect(ordinal('en', 1), '1st');
      expect(ordinal('en', 12), '12th');
      expect(ordinal('en', 23), '23rd');
      expect(displayCode('K7Q29M'), 'K7Q-29M');
      expect(tableOf('t9-2-3'), 4);
      expect(knockoutStage(6, 3), '1/8');
      expect(knockoutStage(6, 6), 'final');
    });
  });

  test('router: Turnirlər tab and the Phase 6 routes resolve', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    String? last(String location) {
      final m = router.configuration.findMatch(Uri.parse(location));
      return m.isError ? null : m.last.route.path;
    }

    expect(last('/tournaments'), '/tournaments');
    expect(last('/tournaments/7'), '/tournaments/:id');
    expect(last('/tournaments/7/bracket'), 'bracket');
    expect(last('/tournaments/7/standings'), 'standings');
    expect(last('/tournaments/join'), '/tournaments/join');
    expect(last('/tournaments/private/new'), '/tournaments/private/new');
    expect(last('/sng?size=16'), '/sng');
    expect(last('/leaderboard'), '/leaderboard');
    expect(last('/season/summary'), '/season/summary');
    expect(last('/puzzles?daily=1'), '/puzzles');
    expect(last('/analysis/match/m1'), '/analysis/match/:id');
    expect(last('/replay/3?analysis=1'), '/replay/:id');
  });

  group('bracket layout (4.3)', () {
    test('cards, connectors and my path from a detail fixture', () {
      final detail = TournamentDetail.fromJson(bracketDetailJson());
      final layout = BracketLayout.of(detail, me: '1');
      expect(layout.rounds, 3);
      expect(layout.stages, ['1/4', '1/2', 'final']);
      expect([for (final c in layout.columns) c.length], [4, 2, 1]);
      // First column at x 14, y 20 + i·120; later rounds centred.
      expect(layout.columns[0][1].rect.topLeft, const Offset(14, 140));
      expect(layout.columns[1][0].rect.topLeft, const Offset(200, 80));
      expect(layout.columns[1][1].rect.top, 320);
      expect(layout.columns[2][0].rect.topLeft, const Offset(386, 200));
      expect(layout.columns[0][0].rect.size, const Size(150, 61));
      // Paired rounds carry their matches, the final is still empty.
      expect(layout.columns[1][0].match?.matchId, 't9-2-0');
      expect(layout.columns[2][0].match, isNull);
      // Two connectors per target; mine leads Elvin into the 1/2.
      expect(layout.connectors, hasLength(6));
      expect(layout.connectors.where((c) => c.mine), hasLength(2));
      final join = layout.connectors.first.points;
      expect(join[1].dx, 14 + 150 + 20);
      expect(
        layout.size,
        const Size(14 + 2 * 186 + 150 + 14, 20 + 3 * 120 + 61 + 20),
      );
      expect(
        layout.myCell('1', nextMatchId: 't9-2-0')?.match?.matchId,
        't9-2-0',
      );
      expect(layout.myCell(null), isNull);
    });
  });

  group('tournament list, detail and registration (4.1, 4.2)', () {
    testWidgets('4.1 list: cards, sit-and-go entry, empty Mənim', (
      tester,
    ) async {
      final api = TournamentFakeApi();
      await pumpPhase6(tester, const TournamentsTab(), api);
      expect(find.text('Bakı Payız Kuboku'), findsOneWidget);
      expect(find.text('Novruz Çempionatı'), findsOneWidget);
      expect(find.text('CANLI · RAUND 3'), findsOneWidget);
      expect(find.text('QEYDİYYAT AÇIQDIR'), findsOneWidget);
      expect(find.text('SIT-AND-GO'), findsOneWidget);
      await tester.tap(find.text('Mənim'));
      await _settle(tester);
      expect(find.text('Hələ turnirin yoxdur'), findsOneWidget);
      await tester.tap(find.text('Gələcək turnirlərə bax'));
      await _settle(tester);
      expect(api.calls, contains('list:upcoming'));
      await closeScreen(tester);
    });

    testWidgets('4.2 register debits with a key, then unregister refunds', (
      tester,
    ) async {
      final api = TournamentFakeApi();
      await pumpPhase6(tester, const TournamentDetailScreen(id: '7'), api);
      expect(find.text('Mükafat fondu'), findsOneWidget);
      expect(find.text('Başlanğıca'), findsOneWidget);
      expect(find.text('Qeydiyyat'), findsOneWidget);
      await tester.tap(find.text('Qeydiyyat'));
      await _settle(tester);
      expect(api.calls, contains('register:7'));
      expect(api.keys.single.length, greaterThanOrEqualTo(8));
      expect(api.wallet.coins, 12450 - 500);
      expect(find.text('Qeydiyyatdan keçdin'), findsOneWidget);
      expect(find.text('Qeydiyyatı ləğv et'), findsOneWidget);

      await tester.tap(find.text('Qeydiyyatı ləğv et'));
      await _settle(tester);
      expect(find.text('Qeydiyyat ləğv edilsin?'), findsOneWidget);
      await tester.tap(find.text('Qeydiyyatı ləğv et').last);
      await _settle(tester);
      expect(api.calls, contains('unregister:7'));
      expect(api.wallet.coins, 12450);
      expect(find.text('Qeydiyyat'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('4.2 not enough coins: disabled CTA and the earn-only note', (
      tester,
    ) async {
      final api = TournamentFakeApi(wallet: const Wallet(coins: 100));
      await pumpPhase6(tester, const TournamentDetailScreen(id: '7'), api);
      expect(find.textContaining('Sikkə yalnız qazanılır'), findsOneWidget);
      await tester.tap(find.text('Qeydiyyat'));
      await _settle(tester);
      expect(api.calls.where((c) => c.startsWith('register')), isEmpty);
      await closeScreen(tester);
    });

    testWidgets('4.3 Hazıram sends tournament.ready for my next match', (
      tester,
    ) async {
      final api = TournamentFakeApi();
      await pumpPhase6(tester, const BracketScreen(id: '9'), api);
      expect(find.text('NÖVBƏTİ MATÇIN · 1/2'), findsOneWidget);
      expect(find.text('Elvin – Kerem_TR'), findsOneWidget);
      await tester.tap(find.text('Hazıram'));
      await _settle(tester);
      expect(find.text('Hazırsan'), findsOneWidget);
      expect(find.text('Rəqib gözlənilir'), findsOneWidget);
      await closeScreen(tester);
    });
  });

  group('season pass (7.1)', () {
    test('claim credits the reward and marks it claimed', () async {
      final api = SeasonFakeApi();
      final c = await _container(api);
      final view = (await c.read(seasonProvider.future))!;
      expect(view.level, 18);
      expect(view.claimableCount, 3); // free 15, 17, 18
      expect(view.reward(17, PassTrack.premium)!.claimable, isFalse);
      await c.read(seasonProvider.notifier).claim(17, PassTrack.free);
      expect(api.calls, ['claim:free:17']);
      expect(
        c.read(seasonProvider).value!.reward(17, PassTrack.free)!.claimed,
        isTrue,
      );
      expect(c.read(inventoryProvider).value!.wallet.coins, 12450 + 200);
      await c.read(seasonProvider.notifier).claimAll();
      expect(c.read(seasonProvider).value!.claimableCount, 0);
    });

    test('premium: insufficient Yaqut is refused; enough unlocks', () async {
      final poor = SeasonFakeApi(wallet: const Wallet(gems: 320));
      final c = await _container(poor);
      await c.read(seasonProvider.future);
      await expectLater(
        c.read(seasonProvider.notifier).buyPremium('key-12345678'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'insufficient_funds',
          ),
        ),
      );
      expect(c.read(seasonProvider).value!.premium, isFalse);

      final rich = SeasonFakeApi(wallet: const Wallet(gems: 1000));
      final c2 = await _container(rich);
      await c2.read(seasonProvider.future);
      await c2.read(seasonProvider.notifier).buyPremium('key-12345678');
      final after = c2.read(seasonProvider).value!;
      expect(after.premium, isTrue);
      // Premium rewards of reached levels become claimable.
      expect(after.reward(18, PassTrack.premium)!.claimable, isTrue);
      expect(c2.read(inventoryProvider).value!.wallet.gems, 50);
    });

    testWidgets('premium sheet offers the covering Yaqut pack when short', (
      tester,
    ) async {
      final api = SeasonFakeApi(wallet: const Wallet(gems: 320));
      await pumpPhase6(
        tester,
        Builder(
          builder:
              (context) => Center(
                child: TextButton(
                  onPressed:
                      () => showNardSheet<bool>(
                        context,
                        builder: (_) => const PremiumPassSheet(price: 950),
                      ),
                  child: const Text('open'),
                ),
              ),
        ),
        api,
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.text('Sezon bileti · Premium'), findsOneWidget);
      expect(find.text('−630 çatmır'), findsOneWidget);
      expect(find.text('1 200 yaqut al'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('a claimable tile claims on tap', (tester) async {
      final api = SeasonFakeApi();
      await pumpPhase6(tester, const SeasonPassScreen(), api);
      expect(find.text('Xəzər'), findsOneWidget);
      expect(find.text('SEZON 4 · 18 GÜN 6 SAAT'), findsOneWidget);
      expect(find.text('Hamısını al · 3'), findsOneWidget);
      await tester.tap(find.text('Hamısını al · 3'));
      await _settle(tester);
      expect(api.calls, contains('claimAll'));
      expect(find.text('Mükafat alındı'), findsOneWidget);
      await closeScreen(tester);
    });
  });

  group('analysis (10.1)', () {
    test('a recorded game is analysed deterministically', () {
      final record = shortGame();
      final tasks = Analyzer.tasks(record);
      expect(tasks, hasLength(6));
      final a = Analyzer.analyseRecord(record);
      final b = Analyzer.analyseRecord(record);
      expect(a, hasLength(6));
      for (var i = 0; i < a.length; i++) {
        expect(a[i].bestEquity, b[i].bestEquity);
        expect(a[i].playedEquity, b[i].playedEquity);
        expect(a[i].bestEquity, greaterThanOrEqualTo(a[i].playedEquity));
        expect(a[i].bestEquity, inInclusiveRange(-1, 1));
        expect(a[i].cls, MoveEval.classify(a[i].loss));
        expect(a[i].side, tasks[i].board.turn);
      }
      // Alternating movers, White first (opening 5-2).
      expect(a.first.side, Side.white);
      expect(a[1].side, Side.black);
    });

    test('the best turn scores 0 loss; a poor one is marked', () {
      const rules = ShortNardRules();
      final board = rules.initialState();
      final roll = DiceRoll(6, 5);
      final evals = [
        for (final t in rules.legalTurns(board, roll))
          Analyzer.analyse(
            AnalysisTask(
              variant: Variant.shortNard,
              board: board,
              roll: roll,
              played: t.moves,
            ),
          ),
      ];
      final best = evals.first.best;
      final bestEval = Analyzer.analyse(
        AnalysisTask(
          variant: Variant.shortNard,
          board: board,
          roll: roll,
          played: best,
        ),
      );
      expect(bestEval.isBest, isTrue);
      expect(bestEval.cls, EvalClass.good);
      final worst = evals.reduce((x, y) => x.loss >= y.loss ? x : y);
      expect(worst.loss, greaterThan(0));
      expect(worst.isBest, isFalse);
      expect(MoveEval.classify(.03), EvalClass.good);
      expect(MoveEval.classify(.05), EvalClass.mistake);
      expect(MoveEval.classify(.142), EvalClass.blunder);
    });

    testWidgets('replay with analysis shows marks, bar and legend', (
      tester,
    ) async {
      final record = shortGame(turns: 4);
      await pumpPhase6(
        tester,
        Consumer(
          builder:
              (context, ref, _) => ReplayView(
                viewer: Side.white,
                white: 'Elvin',
                black: 'Kompüter',
                record: record,
                frames: buildFrames(record, AppLocalizations.of(context)),
                gameNumber: 3,
                analysis: true,
              ),
        ),
        FakeApi(),
      );
      await _settle(tester);
      expect(find.text('Təhlil · Oyun 3'), findsOneWidget);
      expect(find.text('Qiymət'), findsOneWidget);
      // Every turn got its mark; no row is still analysing.
      expect(find.byType(EvalMark), findsNWidgets(4));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Step past the opening roll to the first turn: bar and legend.
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.bySemanticsLabel('İrəli').first);
        await _settle(tester);
      }
      expect(find.byType(EvalBar), findsOneWidget);
      expect(find.byType(ArrowsLegend), findsOneWidget);
      await closeScreen(tester);
    });
  });

  group('puzzles (13.x)', () {
    test('the attempt body is the board after my moves, own numbering', () {
      const rules = ShortNardRules();
      final start = rules.initialState();
      final json = PuzzleBoard.toJson(start);
      // Each side in its own numbering: the start is symmetric.
      expect(json['white'], json['black']);
      expect(json['white'], {'24': 2, '13': 5, '8': 3, '6': 5});
      final back = PuzzleBoard.fromJson(json, Side.white);
      expect(PuzzleBoard.toJson(back), json);

      final puzzle = Puzzle(
        id: 'sn-001',
        variant: Variant.shortNard,
        side: Side.white,
        dice: DiceRoll(3, 1),
        board: start,
      );
      var input = PuzzleInput(puzzle);
      expect(input.canConfirm, isFalse);
      input = input.move(8, 5).move(6, 5);
      expect(input.canConfirm, isTrue);
      final body = input.attemptBoard();
      expect(body['white'], {'24': 2, '13': 5, '8': 2, '6': 4, '5': 2});
      expect(body['black'], json['black']);
      // Any order reaching the same position sends the same board.
      final other = PuzzleInput(puzzle).move(6, 5).move(8, 5).attemptBoard();
      expect(other, body);
      expect(
        body,
        PuzzleBoard.toJson(rules.apply(start, DiceRoll(3, 1), input.pending)),
      );
      expect(input.undo().pending, hasLength(1));
      expect(input.notation, isNotEmpty);
      // Tap-tap: select 8, tap 5.
      final tapped = PuzzleInput(puzzle).tap(8).tap(5);
      expect(tapped.pending, hasLength(1));
      expect(tapped.selected, isNull);
    });

    testWidgets('13.1 renders the puzzle, context and tags', (tester) async {
      final api = PuzzleFakeApi();
      await pumpPhase6(tester, const PuzzleScreen(), api);
      expect(find.text('Tapmaca 14 / 30'), findsOneWidget);
      expect(find.text('Reytinq 1420'), findsOneWidget);
      expect(find.text('Ən yaxşı gedişi tap'), findsOneWidget);
      expect(find.text('Ağ daşlarla oynayırsan. Zər: 3 – 1.'), findsOneWidget);
      expect(find.text('Açılış'), findsOneWidget);
      expect(find.text('Gedişi təsdiqlə'), findsOneWidget);
      await closeScreen(tester);
    });
  });

  group('render 390×844', () {
    final screens = <String, (Widget, FakeApi Function())>{
      '4.4 standings': (const StandingsScreen(id: '11'), TournamentFakeApi.new),
      '21.1 sit-and-go lobby': (
        const SngScreen(size: 16),
        TournamentFakeApi.new,
      ),
      '22.1 private settings': (
        const CreatePrivateTournamentScreen(),
        TournamentFakeApi.new,
      ),
      '22.2 invite': (
        const PrivateTournamentScreen(id: '30'),
        TournamentFakeApi.new,
      ),
      'join by code': (const JoinTournamentScreen(), TournamentFakeApi.new),
      '6.5 leaderboard': (const LeaderboardScreen(), SeasonFakeApi.new),
      '7.2 season summary': (const SeasonSummaryScreen(), SeasonFakeApi.new),
    };
    for (final e in screens.entries) {
      testWidgets(e.key, (tester) async {
        await pumpPhase6(tester, e.value.$1, e.value.$2());
        expect(tester.takeException(), isNull);
        await closeScreen(tester);
      });
    }

    testWidgets('4.5 champion, 21.2 no-show, 21.3 walkover, 21.4 refund', (
      tester,
    ) async {
      final finished = TournamentDetail.fromJson({
        ...bracketDetailJson(),
        'status': 'finished',
        'myStatus': 'champion',
        'myPlace': 1,
      });
      await pumpPhase6(tester, ChampionView(detail: finished), FakeApi());
      expect(find.text('Çempion'), findsOneWidget);
      expect(find.text('+25 000 sikkə'), findsOneWidget);
      expect(find.text('Titul: Daimi'), findsOneWidget);
      await closeScreen(tester);

      final ready = TournamentReadyStatePayload(
        matchId: 't9-1-3',
        tournamentId: '9',
        round: 1,
        you: Side.white,
        white: const PlayerInfo(userId: '1', name: 'Elvin'),
        black: const PlayerInfo(userId: '8', name: 'Rauf_88'),
        ready: const {Side.white: true, Side.black: false},
        deadline: DateTime.now().millisecondsSinceEpoch + 47000,
      );
      await pumpPhase6(tester, NoShowScreen(state: ready), FakeApi());
      expect(find.text('RAUND 1 · MASA 4'), findsOneWidget);
      expect(find.text('Rəqib hələ qoşulmayıb'), findsOneWidget);
      expect(find.textContaining('Rauf_88 vaxt bitənə qədər'), findsOneWidget);
      await closeScreen(tester);

      await pumpPhase6(
        tester,
        const WalkoverScreen(
          walkover: TournamentWalkoverPayload(
            matchId: 't9-1-3',
            tournamentId: '9',
            winner: Side.white,
          ),
        ),
        FakeApi(),
      );
      expect(find.text('Növbəti raunda keçdin'), findsOneWidget);
      expect(find.text('Raund 2 başlayır'), findsOneWidget);
      await closeScreen(tester);

      final cancelled = Tournament.fromJson(
        tournamentJson(
          kind: 'sit_and_go',
          status: 'cancelled',
          size: 32,
          entrants: 19,
        ),
      );
      await pumpPhase6(
        tester,
        NotFilledScreen(tournament: cancelled),
        FakeApi(),
      );
      expect(find.text('Turnir başlamadı'), findsOneWidget);
      expect(find.text('+500 qaytarıldı'), findsOneWidget);
      expect(find.text('16 nəfərlik masaya qoşul'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('6.5 leaderboard rows and my pinned row', (tester) async {
      final board = await SeasonFakeApi().leaderboard(
        Variant.shortNard,
        LeaderboardScope.global,
      );
      await pumpPhase6(
        tester,
        LeaderboardBody(board: board, scope: LeaderboardScope.global),
        SeasonFakeApi(),
      );
      expect(find.text('Rauf'), findsOneWidget);
      expect(find.text('Nigar_88'), findsOneWidget);
      expect(find.text('#412'), findsOneWidget);
      expect(find.text('Elvin (sən)'), findsOneWidget);
      await closeScreen(tester);
    });
  });
}
