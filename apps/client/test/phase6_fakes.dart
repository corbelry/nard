import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/analysis/analysis_engine.dart';
import 'package:nard_client/analysis/analysis_providers.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/puzzles/puzzle_models.dart';
import 'package:nard_client/seasons/season_models.dart';
import 'package:nard_client/store/store_models.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_client/tournaments/tournament_models.dart';
import 'package:nard_client/tournaments/tournament_providers.dart';
import 'package:nard_core/nard_core.dart';

import 'store_fakes.dart';

UserLite user(String id, String name) => UserLite(id: id, name: name);

Map<String, Object?> userJson(String id, String name) => {
  'id': id,
  'name': name,
  'country': 'AZ',
  'avatar': null,
};

/// `Tournament` summary JSON as the API sends it.
Map<String, Object?> tournamentJson({
  String id = '7',
  String name = 'Novruz Çempionatı',
  String type = 'knockout',
  String kind = 'scheduled',
  String status = 'registering',
  int size = 64,
  int entrants = 48,
  int coins = 500,
  int currentRound = 0,
  int? totalRounds = 6,
  String myStatus = 'none',
  int? myPlace,
  DateTime? startsAt,
}) => {
  'id': id,
  'name': {'az': name, 'en': name},
  'type': type,
  'kind': kind,
  'status': status,
  'variant': 'shortNard',
  'matchLength': 7,
  'clock': {'reserveMs': 180000, 'delayMs': 12000},
  'size': size,
  'minPlayers': 4,
  'entrants': entrants,
  'entry': {'kind': coins > 0 ? 'coins' : 'free', 'coins': coins},
  'minRating': null,
  'rated': false,
  'private': false,
  'startsAt':
      (startsAt ?? DateTime.now().add(const Duration(hours: 2)))
          .toUtc()
          .toIso8601String(),
  'expiresAt': null,
  'startedAt': null,
  'finishedAt': null,
  'cancelReason': null,
  'currentRound': currentRound,
  'totalRounds': totalRounds,
  'prizes': [
    {
      'from': 1,
      'to': 1,
      'coins': 25000,
      'items': ['title.regular'],
    },
    {'from': 2, 'to': 2, 'coins': 12000, 'items': <String>[]},
    {'from': 3, 'to': 4, 'coins': 6500, 'items': <String>[]},
  ],
  'prizeFund': 50000,
  'fairDice': true,
  'myStatus': myStatus,
  'myPlace': myPlace,
};

Map<String, Object?> matchJson(
  int round,
  int slot,
  (String, String)? white,
  (String, String)? black, {
  String status = 'pending',
  String? result,
  (int, int)? score,
}) => {
  'slot': slot,
  'matchId': 't9-$round-$slot',
  'white': white == null ? null : userJson(white.$1, white.$2),
  'black': black == null ? null : userJson(black.$1, black.$2),
  'status': status,
  'result': result,
  'winnerId':
      result == 'white'
          ? white?.$1
          : result == 'black'
          ? black?.$1
          : null,
  'score': score == null ? null : [score.$1, score.$2],
};

/// A live 8-player knockout in round 2: I (id 1, Elvin) won round 1 and
/// my 1/2 match is ready.
Map<String, Object?> bracketDetailJson() => {
  ...tournamentJson(
    id: '9',
    name: 'Bakı Payız Kuboku',
    status: 'running',
    size: 8,
    entrants: 8,
    currentRound: 2,
    totalRounds: 3,
    myStatus: 'playing',
  ),
  'organizerId': null,
  'inviteCode': null,
  'entrantsList': [
    for (var i = 1; i <= 8; i++)
      {'user': userJson('$i', 'P$i'), 'seed': i, 'rating': 1500, 'place': null},
  ],
  'rounds': [
    {
      'number': 1,
      'stage': '1/4',
      'status': 'finished',
      'matches': [
        matchJson(
          1,
          0,
          ('1', 'Elvin'),
          ('8', 'Rauf'),
          status: 'finished',
          result: 'white',
          score: (7, 4),
        ),
        matchJson(
          1,
          1,
          ('4', 'Nigar_88'),
          ('5', 'Kerem_TR'),
          status: 'finished',
          result: 'black',
          score: (3, 7),
        ),
        matchJson(
          1,
          2,
          ('2', 'Aysel_A'),
          ('7', 'Orxan'),
          status: 'walkover',
          result: 'white',
        ),
        matchJson(
          1,
          3,
          ('3', 'Murad'),
          ('6', 'Günay'),
          status: 'finished',
          result: 'white',
          score: (7, 6),
        ),
      ],
    },
    {
      'number': 2,
      'stage': '1/2',
      'status': 'running',
      'matches': [
        matchJson(2, 0, ('1', 'Elvin'), ('5', 'Kerem_TR'), status: 'ready'),
        matchJson(2, 1, ('2', 'Aysel_A'), ('3', 'Murad'), score: (2, 1)),
      ],
    },
  ],
  'standings': null,
  'myNextMatch': {
    'matchId': 't9-2-0',
    'round': 2,
    'status': 'ready',
    'opponent': userJson('5', 'Kerem_TR'),
    'noShowSeconds': 60,
  },
};

/// A Swiss table after round 3 of 5 with me (id 1) third.
Map<String, Object?> swissDetailJson() => {
  ...tournamentJson(
    id: '11',
    name: 'Gecə Liqası',
    type: 'swiss',
    status: 'running',
    size: 16,
    entrants: 12,
    currentRound: 3,
    totalRounds: 5,
    myStatus: 'playing',
  ),
  'rounds': const <Object?>[],
  'entrantsList': const <Object?>[],
  'standings': [
    for (final (i, n, w) in [
      (2, 'Rauf', 3),
      (3, 'Aysel_A', 3),
      (1, 'Elvin', 2),
      (4, 'Kerem_TR', 2),
      (5, 'Murad', 1),
      (6, 'Samir_77', 0),
    ])
      {
        'rank': [2, 3, 1, 4, 5, 6].indexOf(i) + 1,
        'user': userJson('$i', n),
        'wins': w,
        'losses': 3 - w,
        'points': w,
        'buchholz': 9 - i,
      },
  ],
  'myNextMatch': null,
};

/// A private 8-player knockout I organise, 3 joined.
Map<String, Object?> privateDetailJson() => {
  ...tournamentJson(
    id: '30',
    name: 'Ofis Kuboku · Noyabr',
    kind: 'private',
    size: 8,
    entrants: 3,
    coins: 0,
    myStatus: 'registered',
  ),
  'entry': {'kind': 'invite', 'coins': 0},
  'private': true,
  'organizerId': '1',
  'inviteCode': 'K7Q29M',
  'entrantsList': [
    {'user': userJson('1', 'Elvin'), 'seed': null, 'rating': 1500},
    {'user': userJson('2', 'Nigar_88'), 'seed': null, 'rating': 1500},
    {'user': userJson('3', 'Rauf'), 'seed': null, 'rating': 1500},
  ],
  'rounds': const <Object?>[],
  'standings': null,
  'myNextMatch': null,
};

/// Tournaments, sit-and-go and private tournaments in memory.
class TournamentFakeApi extends FakeApi {
  TournamentFakeApi({super.wallet});

  final keys = <String>[];
  var detail = TournamentDetail.fromJson({
    ...tournamentJson(),
    'rounds': const <Object?>[],
    'entrantsList': const <Object?>[],
    'standings': null,
    'myNextMatch': null,
  });

  @override
  Future<List<Tournament>> tournaments(
    TournamentTab tab, {
    Variant? variant,
    bool free = false,
  }) async {
    calls.add('list:${tab.name}');
    if (tab == TournamentTab.mine) return const [];
    return [
      Tournament.fromJson(
        tournamentJson(
          id: '9',
          name: 'Bakı Payız Kuboku',
          status: 'running',
          currentRound: 3,
          entrants: 64,
        ),
      ),
      detail.tournament,
    ];
  }

  @override
  Future<TournamentDetail> tournament(String id) async => switch (id) {
    '9' => TournamentDetail.fromJson(bracketDetailJson()),
    '11' => TournamentDetail.fromJson(swissDetailJson()),
    '30' => TournamentDetail.fromJson(privateDetailJson()),
    _ => detail,
  };

  TournamentDetail _with(String myStatus, int entrants) =>
      TournamentDetail.fromJson({
        ...tournamentJson(myStatus: myStatus, entrants: entrants),
        'rounds': const <Object?>[],
        'entrantsList': const <Object?>[],
        'standings': null,
        'myNextMatch': null,
      });

  @override
  Future<(Tournament, Wallet)> registerTournament(
    String id, {
    String? idempotencyKey,
    String? code,
  }) async {
    calls.add('register:$id');
    final t = detail.tournament;
    if (t.paid && idempotencyKey == null) {
      throw const ApiException(422, 'idempotency_key_required');
    }
    keys.add(idempotencyKey ?? '');
    if (wallet.coins < t.entryCoins) {
      throw const ApiException(422, 'insufficient_coins');
    }
    wallet = Wallet(coins: wallet.coins - t.entryCoins, gems: wallet.gems);
    detail = _with('registered', t.entrants + 1);
    return (detail.tournament, wallet);
  }

  @override
  Future<(Tournament, Wallet)> unregisterTournament(String id) async {
    calls.add('unregister:$id');
    final t = detail.tournament;
    wallet = Wallet(coins: wallet.coins + t.entryCoins, gems: wallet.gems);
    detail = _with('none', t.entrants - 1);
    return (detail.tournament, wallet);
  }

  @override
  Future<List<SngTable>> sngTables() async => [
    for (final size in const [8, 16, 32])
      SngTable.fromJson({
        'size': size,
        'variant': 'shortNard',
        'matchLength': 3,
        'clock': {'reserveMs': 120000, 'delayMs': 12000},
        'entry': {'kind': 'coins', 'coins': 500},
        'prizeFund': size * 450,
        'prizes': null,
        'tournamentId': size == 16 ? '20' : null,
        'joined': size == 16 ? 11 : 0,
        'expiresAt': null,
        'registered': size == 16,
      }),
  ];
}

/// Season pass in memory: level 18, free claimable 17, premium 950.
class SeasonFakeApi extends FakeApi {
  SeasonFakeApi({super.wallet});

  bool premium = false;
  final claimed = <String>{'free:16'};

  SeasonView _view() {
    const level = 18;
    final rewards = <Map<String, Object?>>[];
    for (var l = 15; l <= 20; l++) {
      for (final track in const ['free', 'premium']) {
        final key = '$track:$l';
        final done = claimed.contains(key);
        final kind = track == 'free' ? 'coins' : (l.isEven ? 'gems' : 'item');
        rewards.add({
          'level': l,
          'track': track,
          'kind': kind,
          'amount': kind == 'item' ? null : (track == 'free' ? 200 : 50),
          'itemId': kind == 'item' ? 'board.caspian' : null,
          'claimed': done,
          'claimable': !done && level >= l && (track == 'free' || premium),
        });
      }
    }
    return SeasonView.fromJson({
      'season': {
        'id': 4,
        'number': 4,
        'name': {'az': 'Xəzər', 'en': 'Caspian'},
        'status': 'active',
        'startsAt': '2026-10-01T00:00:00Z',
        'endsAt': '2026-11-12T00:00:00Z',
        'secondsLeft': 18 * 86400 + 6 * 3600,
      },
      'pass': {
        'levels': 50,
        'xpPerLevel': 1000,
        'xp': 18640,
        'level': level,
        'levelXp': 640,
        'premium': premium,
        'premiumPrice': {'gems': 950},
        'rewards': rewards,
      },
      'endRewards': [
        {
          'tier': 'diamond',
          'minRating': 1900,
          'coins': 2000,
          'itemId': 'title.regular',
        },
      ],
      'currentTier': 'platinum',
      'myTarget': {'tier': 'diamond', 'minRating': 1900, 'pointsLeft': 158},
    });
  }

  @override
  Future<SeasonView> season() async => _view();

  @override
  Future<List<Season>> seasons() async => [_view().season];

  @override
  Future<Leaderboard> leaderboard(
    Variant variant,
    LeaderboardScope scope, {
    int? season,
  }) async => Leaderboard.fromJson({
    'minMatches': 5,
    'entries': [
      for (final (i, n, r) in [
        (1, 'Rauf', 2210),
        (2, 'Aysel_A', 2105),
        (3, 'Orxan', 2040),
        (4, 'Nigar_88', 1990),
        (5, 'Fərid', 1972),
        (6, 'Leyla', 1961),
      ])
        {
          'rank': i,
          'user': userJson('${i + 10}', n),
          'rating': r,
          'tier': 'diamond',
        },
    ],
    'me': {
      'rank': 412,
      'rating': 1866,
      'tier': 'platinum',
      'matches': 40,
      'user': userJson('1', 'Elvin'),
    },
  });

  @override
  Future<SeasonSummary> seasonSummary([int? number]) async =>
      SeasonSummary.fromJson({
        'season': {
          'id': 3,
          'number': 3,
          'name': {'az': 'Payız'},
          'status': 'finished',
          'secondsLeft': 0,
        },
        'results': [
          {
            'variant': 'shortNard',
            'rank': 1200,
            'countryRank': 412,
            'tier': 'diamond',
            'rating': 1934,
            'ratingDelta': 386,
            'matches': 214,
            'wins': 131,
            'winRate': 61,
          },
        ],
        'reward': {'tier': 'diamond', 'coins': 2000, 'itemId': null},
        'ratings': {'shortNard': 1717},
      });

  @override
  Future<(SeasonView, Wallet)> claimPassReward(
    int level,
    PassTrack track,
  ) async {
    calls.add('claim:${track.name}:$level');
    final r = _view().reward(level, track);
    if (r == null || !r.claimable) {
      throw const ApiException(422, 'not_reached');
    }
    claimed.add('${track.name}:$level');
    wallet = Wallet(
      coins: wallet.coins + (r.kind == RewardKind.coins ? r.amount ?? 0 : 0),
      gems: wallet.gems + (r.kind == RewardKind.gems ? r.amount ?? 0 : 0),
    );
    return (_view(), wallet);
  }

  @override
  Future<(SeasonView, Wallet)> claimAllPassRewards() async {
    calls.add('claimAll');
    for (final r in _view().rewards.where((r) => r.claimable)) {
      await claimPassReward(r.level, r.track);
    }
    return (_view(), wallet);
  }

  @override
  Future<(SeasonView, Wallet)> buySeasonPremium(String idempotencyKey) async {
    calls.add('premium:$idempotencyKey');
    if (premium) throw const ApiException(422, 'already_owned');
    if (wallet.gems < 950) throw const ApiException(422, 'insufficient_funds');
    wallet = Wallet(coins: wallet.coins, gems: wallet.gems - 950);
    premium = true;
    return (_view(), wallet);
  }
}

/// A puzzle on the Short Nard start position, dice 3-1 for White.
class PuzzleFakeApi extends FakeApi {
  final attempts = <Map<String, Object?>>[];

  static Map<String, Object?> get start =>
      PuzzleBoard.toJson(const ShortNardRules().initialState());

  @override
  Future<PuzzleBatch> nextPuzzle({Variant? variant}) async =>
      PuzzleBatch.fromJson({
        'puzzle': {
          'id': 'sn-001',
          'variant': 'shortNard',
          'phase': 'opening',
          'difficulty': 'medium',
          'rating': 1420,
          'side': 'white',
          'dice': [3, 1],
          'board': start,
          'attemptsUsed': 0,
          'finished': false,
          'correct': false,
        },
        'rating': 1420,
        'solved': 13,
        'total': 30,
      });

  @override
  Future<PuzzleBatch> dailyPuzzle() => nextPuzzle();

  @override
  Future<AttemptResult> attemptPuzzle(
    String id,
    int attempt,
    Map<String, Object?> board, {
    String? moves,
  }) async {
    attempts.add(board);
    return AttemptResult.fromJson({
      'attempt': attempt,
      'correct': false,
      'finished': false,
      'attemptsLeft': 1,
      'ratingDelta': -8,
      'rating': 1412,
      'solution': null,
    });
  }
}

/// Keeps the game-server socket closed in tests.
class FakeTournamentSocket extends TournamentSocket {
  final readySent = <String>[];

  @override
  void connect() {}

  @override
  void ready(String matchId) {
    readySent.add(matchId);
    state = state.copyWith(sent: {...state.sent, matchId});
  }
}

/// Runs analysis inline (no isolates in widget tests).
Future<MoveEval> inlineAnalysis(AnalysisTask task) async =>
    Analyzer.analyse(task);

List<Override> phase6Overrides(FakeApi api) => [
  ...storeOverrides(api),
  tournamentSocketProvider.overrideWith(FakeTournamentSocket.new),
  analysisRunnerProvider.overrideWithValue(inlineAnalysis),
];

/// Pumps [screen] at 390 × 844 (az) under a router whose other routes
/// render `route:<location>`.
Future<void> pumpPhase6(
  WidgetTester tester,
  Widget screen,
  FakeApi api, {
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => Scaffold(body: screen))],
    errorBuilder: (_, s) => Scaffold(body: Text('route:${s.uri}')),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...phase6Overrides(api), ...extra],
      child: MaterialApp.router(
        theme: NardTheme.build(NardColors.defaultTheme),
        locale: const Locale('az'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}
