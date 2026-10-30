import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart' show TimeControl;

import '../clans/clan_models.dart';
import '../cosmetics/catalog.dart';
import '../notifications/notification_models.dart';
import '../progression/progress_models.dart';
import '../puzzles/puzzle_models.dart';
import '../seasons/season_models.dart';
import '../social/social_models.dart';
import '../store/store_models.dart';
import '../tournaments/tournament_models.dart';

/// An API error with its machine code (e.g. `code_invalid`).
class ApiException implements Exception {
  const ApiException(
    this.status,
    this.code, [
    this.message = '',
    this.data = const {},
  ]);

  final int status;
  final String code;
  final String message;

  /// The whole error body (e.g. `until` of `banned` / `muted`).
  final Map<String, Object?> data;

  /// No connection (status 0).
  bool get offline => status == 0;

  /// `until` of a `banned` / `muted` answer, local time; null = permanent
  /// or absent.
  DateTime? get until => DateTime.tryParse('${data['until'] ?? ''}')?.toLocal();

  @override
  String toString() => 'ApiException($status, $code)';
}

/// A `403 {code: banned, until}` answer (ADR-042).
class AccountBan {
  const AccountBan({this.until});

  /// Local time the ban ends; null = permanent.
  final DateTime? until;

  bool get permanent => until == null;
}

/// `POST /game/ticket`: the ticket and the matchmaking cooldown it carries
/// (abandonment penalty, ADR-042).
class GameTicket {
  const GameTicket(this.ticket, {this.queueCooldownUntil});

  final String ticket;

  /// Local time the public queue reopens; null = no cooldown.
  final DateTime? queueCooldownUntil;
}

/// The player's account as returned by the API.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.guest,
    this.email,
    this.country,
    this.locale = 'az',
    this.ratings = const {},
    this.friendCode,
    this.clan,
  });

  final String id;
  final String name;
  final bool guest;
  final String? email;
  final String? country;
  final String locale;

  /// variant name → {rating, peak, matches, wins, tier}.
  final Map<String, RatingInfo> ratings;

  /// 8-character friend code (6.2).
  final String? friendCode;

  /// The player's clan with name and role, null when clanless.
  final ClanBadge? clan;

  static Account fromJson(Map<String, Object?> j) {
    final ratings = j['ratings'];
    final clan = j['clan'];
    return Account(
      id: j['id']! as String,
      name: j['name']! as String,
      guest: j['guest']! as bool,
      email: j['email'] as String?,
      country: j['country'] as String?,
      locale: j['locale'] as String? ?? 'az',
      friendCode: j['friendCode'] as String?,
      clan: clan is Map<String, Object?> ? ClanBadge.fromJson(clan) : null,
      ratings:
          ratings is Map<String, Object?>
              ? {
                for (final e in ratings.entries)
                  e.key: RatingInfo.fromJson(e.value! as Map<String, Object?>),
              }
              : const {},
    );
  }
}

class RatingInfo {
  const RatingInfo({
    required this.rating,
    required this.peak,
    required this.matches,
    required this.wins,
    required this.tier,
  });

  final int rating;
  final int peak;
  final int matches;
  final int wins;
  final String tier;

  static RatingInfo fromJson(Map<String, Object?> j) => RatingInfo(
    rating: j['rating']! as int,
    peak: j['peak']! as int,
    matches: j['matches']! as int,
    wins: j['wins']! as int,
    tier: j['tier']! as String,
  );
}

/// Thin client for the Laravel API (apps/api/routes/api.php).
class ApiClient {
  ApiClient(this.baseUrl, {http.Client? client, this.token})
    : _http = client ?? http.Client();

  final String baseUrl;
  final http.Client _http;
  String? token;

  final _reachability = StreamController<bool>.broadcast();
  bool _reachable = true;

  /// Whether the last request reached the server (any HTTP status counts).
  bool get reachable => _reachable;

  /// Emits when [reachable] changes (offline banner, 11.1).
  Stream<bool> get reachability => _reachability.stream;

  final _bans = StreamController<AccountBan>.broadcast();
  AccountBan? _ban;

  /// The last `banned` answer for the current credentials (or a refused
  /// sign-in); cleared by [clearBan].
  AccountBan? get ban => _ban;

  /// Emits every `banned` answer (the full-screen banned state listens).
  Stream<AccountBan> get bans => _bans.stream;

  /// Forgets the ban (after signing out, or once it ran out).
  void clearBan() => _ban = null;

  void _reached(bool value) {
    if (value == _reachable) return;
    _reachable = value;
    _reachability.add(value);
  }

  Future<Map<String, Object?>> _call(
    String method,
    String path, [
    Map<String, Object?>? body,
  ]) async {
    final req = http.Request(method, Uri.parse('$baseUrl/api/v1$path'))
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) req.body = jsonEncode(body);
    final sentToken = token;
    final http.Response res;
    try {
      res = await http.Response.fromStream(
        await _http.send(req).timeout(const Duration(seconds: 15)),
      );
    } on Object catch (e) {
      _reached(false);
      throw ApiException(0, 'offline', '$e');
    }
    _reached(true);
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    final json =
        decoded is Map<String, Object?> ? decoded : <String, Object?>{};
    if (res.statusCode >= 300) {
      final error = ApiException(
        res.statusCode,
        json['code'] as String? ??
            (res.statusCode == 422 ? 'validation' : 'http_${res.statusCode}'),
        json['message'] as String? ?? '',
        json,
      );
      // Ignore late answers to requests made with credentials since
      // dropped (e.g. a poll that returns after signing out).
      if (error.status == 403 && error.code == 'banned' && token == sentToken) {
        final ban = AccountBan(until: error.until);
        _ban = ban;
        _bans.add(ban);
      }
      throw error;
    }
    return json;
  }

  Future<(String, Account)> _signedIn(Map<String, Object?> json) async {
    final t = json['token']! as String;
    token = t;
    return (t, Account.fromJson(json['user']! as Map<String, Object?>));
  }

  Future<(String, Account)> guest(String deviceId, String locale) async =>
      _signedIn(
        await _call('POST', '/auth/guest', {
          'deviceId': deviceId,
          'locale': locale,
        }),
      );

  Future<void> emailStart(String email, String locale) =>
      _call('POST', '/auth/email/start', {'email': email, 'locale': locale});

  Future<(String, Account)> emailVerify(String email, String code) async =>
      _signedIn(
        await _call('POST', '/auth/email/verify', {
          'email': email,
          'code': code,
        }),
      );

  /// Apple / Google sign-in (503 `provider_disabled` until configured).
  Future<(String, Account)> provider(String name, String idToken) async =>
      _signedIn(await _call('POST', '/auth/$name', {'token': idToken}));

  /// Any answer (even 401) means the API is reachable again.
  Future<void> probe() async {
    try {
      await _call('GET', '/me');
    } on ApiException {
      // Only reachability matters here.
    }
  }

  Future<void> logout() => _call('POST', '/auth/logout');

  Future<Account> me() async => Account.fromJson(
    (await _call('GET', '/me'))['user']! as Map<String, Object?>,
  );

  Future<Account> updateMe(Map<String, Object?> fields) async =>
      Account.fromJson(
        (await _call('PATCH', '/me', fields))['user']! as Map<String, Object?>,
      );

  Future<void> deleteMe() => _call('DELETE', '/me');

  /// 15.2: queues the e-mailed ZIP; returns the address it goes to
  /// (`409 email_required` for accounts without one, QUESTIONS #17).
  Future<String> requestExport() async =>
      (await _call('POST', '/me/export'))['email']! as String;

  Future<List<Map<String, Object?>>> matches({int limit = 30}) async =>
      ((await _call('GET', '/me/matches?limit=$limit'))['matches']! as List)
          .cast<Map<String, Object?>>();

  Future<Map<String, Object?>> match(String id) async =>
      (await _call('GET', '/me/matches/$id'))['match']! as Map<String, Object?>;

  /// A short-lived game-server ticket.
  Future<String> ticket() async => (await gameTicket()).ticket;

  /// The ticket with its matchmaking cooldown (`queueCooldownUntil`).
  Future<GameTicket> gameTicket() async {
    final j = await _call('POST', '/game/ticket');
    return GameTicket(
      j['ticket']! as String,
      queueCooldownUntil:
          DateTime.tryParse('${j['queueCooldownUntil'] ?? ''}')?.toLocal(),
    );
  }

  // ---- Phase 4: cosmetics, store, progression ------------------------

  Future<Catalog> catalog() async =>
      Catalog.fromJson(await _call('GET', '/catalog'));

  Future<Inventory> inventory() async =>
      Inventory.fromJson(await _call('GET', '/me/inventory'));

  /// Buys [itemId]; idempotent by [idempotencyKey] (8–64 chars). Throws
  /// 422 `insufficient_funds` | `already_owned` | `not_for_sale`.
  Future<PurchaseResult> purchase(
    String itemId,
    Currency currency,
    String idempotencyKey,
  ) async => PurchaseResult.fromJson(
    await _call('POST', '/store/purchase', {
      'itemId': itemId,
      'currency': currency.name,
      'idempotencyKey': idempotencyKey,
    }),
  );

  /// Creates ([id] null) or updates a loadout (max 5).
  Future<Loadout> saveLoadout(
    String name,
    Map<String, String> slots, {
    int? id,
  }) async => Loadout.fromJson(
    (await _call(
          id == null ? 'POST' : 'PUT',
          '/me/loadouts${id == null ? '' : '/$id'}',
          {'name': name, 'slots': slots},
        ))['loadout']!
        as Map<String, Object?>,
  );

  Future<void> deleteLoadout(int id) => _call('DELETE', '/me/loadouts/$id');

  Future<void> activateLoadout(int id) =>
      _call('POST', '/me/loadouts/$id/activate');

  Future<StoreOffers> offers() async =>
      StoreOffers.fromJson(await _call('GET', '/store/offers'));

  Future<GemProducts> products() async =>
      GemProducts.fromJson(await _call('GET', '/store/products'));

  /// Redeems a store receipt; returns the new Yaqut balance. 503
  /// `iap_disabled` until the store accounts exist.
  Future<int> redeemIap(
    String platform,
    String productId,
    String receipt,
  ) async =>
      ((await _call('POST', '/store/iap/$platform', {
                'productId': productId,
                'receipt': receipt,
              }))['gems']
              as num?)
          ?.toInt() ??
      0;

  Future<Progress> progress() async =>
      Progress.fromJson(await _call('GET', '/me/progress'));

  Future<CheckIn> checkIn() async =>
      CheckIn.fromJson(await _call('POST', '/me/checkin'));

  /// Throws 422 `not_claimable`.
  Future<ClaimResult> claimMission(String id) async =>
      ClaimResult.fromJson(await _call('POST', '/me/missions/$id/claim'));

  Future<void> setTitle(String? itemId) =>
      _call('PUT', '/me/title', {'itemId': itemId});

  // ---- Phase 5: friends, blocks, reports, challenges ------------------

  Future<FriendsOverview> friends() async =>
      FriendsOverview.fromJson(await _call('GET', '/friends'));

  /// By 8-character [code] or [userId]. 422 `self` | `blocked` |
  /// `already_friends` | `already_requested` | `too_many_friends`; 404.
  Future<FriendRequestStatus> requestFriend({
    String? code,
    String? userId,
  }) async {
    final json = await _call('POST', '/friends/requests', {
      if (code != null) 'code': code,
      if (userId != null) 'userId': userId,
    });
    return json['status'] == 'accepted'
        ? FriendRequestStatus.accepted
        : FriendRequestStatus.requested;
  }

  Future<void> acceptFriend(int requestId) =>
      _call('POST', '/friends/requests/$requestId/accept');

  /// Declines an incoming or cancels an outgoing request.
  Future<void> dismissFriend(int requestId) =>
      _call('DELETE', '/friends/requests/$requestId');

  Future<void> unfriend(String userId) => _call('DELETE', '/friends/$userId');

  /// Prefix search on names ([query] 3–20 chars).
  Future<List<PublicUser>> searchUsers(String query) async => [
    for (final u
        in ((await _call(
                  'GET',
                  '/users/search?q=${Uri.encodeQueryComponent(query)}',
                ))['users']
                as List?) ??
            const [])
      if (u is Map<String, Object?>) PublicUser.fromJson(u),
  ];

  Future<List<PublicUser>> blocks() async => [
    for (final u in ((await _call('GET', '/blocks'))['users'] as List?) ?? [])
      if (u is Map<String, Object?>) PublicUser.fromJson(u),
  ];

  /// Also ends a friendship (server side).
  Future<void> block(String userId) => _call('POST', '/blocks/$userId');

  Future<void> unblock(String userId) => _call('DELETE', '/blocks/$userId');

  /// Returns the reference ("R-000123"). 429 `rate_limited`.
  Future<String> report(
    String userId,
    ReportReason reason, {
    String? matchId,
    String? note,
  }) async =>
      (await _call('POST', '/reports', {
            'userId': userId,
            'reason': reason.name,
            if (matchId != null) 'matchId': matchId,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          }))['reference']
          as String? ??
      '';

  /// Invites a friend into my private room [code] (shown on their 6.1),
  /// with the room's clock (ADR-044).
  Future<void> challenge(
    String userId,
    String code,
    Variant variant,
    int matchLength, {
    required TimeControl timeControl,
  }) => _call('POST', '/challenges', {
    'userId': userId,
    'code': code,
    'variant': variant.name,
    'matchLength': matchLength,
    'timeControl': timeControl.name,
  });

  // ---- Phase 5: clans (docs/api/clans.md) ------------------------------

  Future<List<ClanSummary>> clans({
    String? query,
    String? language,
    JoinPolicy? policy,
    int? maxMinRating,
  }) async {
    final params = {
      if (query != null && query.trim().length >= 2) 'q': query.trim(),
      if (language != null) 'language': language,
      if (policy != null) 'policy': policy.name,
      if (maxMinRating != null) 'maxMinRating': '$maxMinRating',
    };
    final qs = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    return [
      for (final c
          in ((await _call('GET', '/clans$qs'))['clans'] as List?) ?? const [])
        if (c is Map<String, Object?>) ClanSummary.fromJson(c),
    ];
  }

  /// (valid, available) of a tag (19.1).
  Future<(bool, bool)> tagAvailable(String tag) async {
    final j = await _call(
      'GET',
      '/clans/tag-available?tag=${Uri.encodeQueryComponent(tag)}',
    );
    return (j['valid'] == true, j['available'] == true);
  }

  Future<ClanLeaderboard> clanLeaderboard() async =>
      ClanLeaderboard.fromJson(await _call('GET', '/clans/leaderboard'));

  /// 422 `already_in_clan` | `insufficient_funds` | `name_taken` |
  /// `tag_taken`.
  Future<(ClanSummary, Wallet)> createClan(
    ClanDraft draft,
    String idempotencyKey,
  ) async {
    final j = await _call('POST', '/clans', {
      ...draft.toJson(),
      'idempotencyKey': idempotencyKey,
    });
    return (
      ClanSummary.fromJson(j['clan']! as Map<String, Object?>),
      Wallet.fromJson(j['wallet']),
    );
  }

  Future<ClanDetail> clan(String id) async => ClanDetail.fromJson(
    (await _call('GET', '/clans/$id'))['clan']! as Map<String, Object?>,
  );

  /// Emblem, policy, rating, language, description (name/tag cost coins
  /// and need [idempotencyKey]).
  Future<void> updateClan(
    String id,
    Map<String, Object?> fields, {
    String? idempotencyKey,
  }) => _call('PATCH', '/clans/$id', {
    ...fields,
    if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
  });

  /// `joined` or `requested`; 422 `invite_only` | `rating_too_low` |
  /// `clan_full` | `already_in_clan`.
  Future<bool> joinClan(String id) async =>
      (await _call('POST', '/clans/$id/join'))['status'] == 'joined';

  Future<void> cancelClanRequest(String id) =>
      _call('DELETE', '/clans/$id/join');

  /// `left` or `disbanded`; 422 `transfer_first`.
  Future<String> leaveClan(String id) async =>
      (await _call('POST', '/clans/$id/leave'))['status'] as String? ?? 'left';

  Future<List<JoinRequest>> clanRequests(String id) async => [
    for (final r
        in ((await _call('GET', '/clans/$id/requests'))['requests'] as List?) ??
            const [])
      if (r is Map<String, Object?>) JoinRequest.fromJson(r),
  ];

  Future<void> acceptClanRequest(String id, int requestId) =>
      _call('POST', '/clans/$id/requests/$requestId/accept');

  Future<void> declineClanRequest(String id, int requestId) =>
      _call('DELETE', '/clans/$id/requests/$requestId');

  Future<void> inviteToClan(String id, String userId) =>
      _call('POST', '/clans/$id/invites', {'userId': userId});

  Future<List<ClanInvite>> clanInvites() async => [
    for (final i
        in ((await _call('GET', '/me/clan-invites'))['invites'] as List?) ??
            const [])
      if (i is Map<String, Object?>) ClanInvite.fromJson(i),
  ];

  Future<void> acceptClanInvite(int inviteId) =>
      _call('POST', '/me/clan-invites/$inviteId/accept');

  Future<void> declineClanInvite(int inviteId) =>
      _call('DELETE', '/me/clan-invites/$inviteId');

  /// [role] `leader` transfers leadership.
  Future<void> setClanRole(String id, String userId, ClanRole role) =>
      _call('POST', '/clans/$id/members/$userId/role', {'role': role.api});

  Future<void> kickMember(String id, String userId) =>
      _call('DELETE', '/clans/$id/members/$userId');

  /// The latest 50 messages after [after], oldest first.
  Future<List<ClanMessage>> clanMessages(String id, {int? after}) async => [
    for (final m
        in ((await _call(
                  'GET',
                  '/clans/$id/messages${after == null ? '' : '?after=$after'}',
                ))['messages']
                as List?) ??
            const [])
      if (m is Map<String, Object?>) ClanMessage.fromJson(m),
  ];

  /// ≤ 300 chars, 10 per minute (429).
  Future<ClanMessage> postClanMessage(String id, String text) async =>
      ClanMessage.fromJson(
        (await _call('POST', '/clans/$id/messages', {'text': text}))['message']!
            as Map<String, Object?>,
      );

  Future<void> deleteClanMessage(String id, int messageId) =>
      _call('DELETE', '/clans/$id/messages/$messageId');

  /// 422 `chest_full` | `insufficient_funds`.
  Future<(ClanChest, Wallet)> donate(
    String id,
    int coins,
    String idempotencyKey,
  ) async {
    final j = await _call('POST', '/clans/$id/donate', {
      'coins': coins,
      'idempotencyKey': idempotencyKey,
    });
    return (
      ClanChest.fromJson(j['chest']! as Map<String, Object?>),
      Wallet.fromJson(j['wallet']),
    );
  }

  Future<ClanWar?> clanWar(String id) async {
    final war = (await _call('GET', '/clans/$id/war'))['war'];
    return war is Map<String, Object?> ? ClanWar.fromJson(war) : null;
  }

  // ---- Phase 6: tournaments (docs/api/tournaments.md) -----------------

  Future<List<Tournament>> tournaments(
    TournamentTab tab, {
    Variant? variant,
    bool free = false,
  }) async {
    final params = {
      'tab': tab.name,
      if (variant != null) 'variant': variant.name,
      if (free) 'free': '1',
    };
    return [
      for (final t
          in ((await _call(
                    'GET',
                    '/tournaments?${Uri(queryParameters: params).query}',
                  ))['tournaments']
                  as List?) ??
              const [])
        if (t is Map<String, Object?>) Tournament.fromJson(t),
    ];
  }

  Future<TournamentDetail> tournament(String id) async =>
      TournamentDetail.fromJson(
        (await _call('GET', '/tournaments/$id'))['tournament']!
            as Map<String, Object?>,
      );

  (Tournament, Wallet) _withWallet(Map<String, Object?> j) => (
    Tournament.fromJson(j['tournament']! as Map<String, Object?>),
    Wallet.fromJson(j['wallet']),
  );

  /// 422 `closed | already_registered | invite_required | rating_too_low |
  /// full | insufficient_coins | idempotency_key_required | …`.
  Future<(Tournament, Wallet)> registerTournament(
    String id, {
    String? idempotencyKey,
    String? code,
  }) async => _withWallet(
    await _call('POST', '/tournaments/$id/register', {
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      if (code != null) 'code': code,
    }),
  );

  /// Before the start only (full refund); 422 `closed | not_registered`.
  Future<(Tournament, Wallet)> unregisterTournament(String id) async =>
      _withWallet(await _call('DELETE', '/tournaments/$id/register'));

  Future<List<SngTable>> sngTables() async => [
    for (final t
        in ((await _call('GET', '/tournaments/sng'))['tables'] as List?) ??
            const [])
      if (t is Map<String, Object?>) SngTable.fromJson(t),
  ];

  Future<(Tournament, Wallet)> joinSng(int size, String idempotencyKey) async =>
      _withWallet(
        await _call('POST', '/tournaments/sng/$size/join', {
          'idempotencyKey': idempotencyKey,
        }),
      );

  /// 22.1: a free knockout with an invite code; 422 `too_many_open`.
  Future<TournamentDetail> createPrivateTournament({
    required String name,
    required int size,
    required Variant variant,
    required int matchLength,
    DateTime? startsAt,
  }) async => TournamentDetail.fromJson(
    (await _call('POST', '/tournaments/private', {
          'name': name,
          'size': size,
          'variant': variant.name,
          'matchLength': matchLength,
          if (startsAt != null) 'startsAt': startsAt.toUtc().toIso8601String(),
        }))['tournament']!
        as Map<String, Object?>,
  );

  /// 404 `not_found`; 422 `closed | full`.
  Future<TournamentDetail> joinTournamentByCode(String code) async =>
      TournamentDetail.fromJson(
        (await _call('POST', '/tournaments/join-by-code', {
              'code': code,
            }))['tournament']!
            as Map<String, Object?>,
      );

  /// Organiser, ≥ 2 entrants; 422 `not_enough_players`.
  Future<void> startTournament(String id) =>
      _call('POST', '/tournaments/$id/start');

  Future<void> cancelTournament(String id) =>
      _call('DELETE', '/tournaments/$id');

  Future<void> removeEntrant(String id, String userId) =>
      _call('DELETE', '/tournaments/$id/entrants/$userId');

  // ---- Phase 6: seasons, leaderboards, puzzles (docs/api/seasons.md) ---

  Future<SeasonView> season() async =>
      SeasonView.fromJson(await _call('GET', '/season'));

  Future<List<Season>> seasons() async => [
    for (final s
        in ((await _call('GET', '/seasons'))['seasons'] as List?) ?? const [])
      if (s is Map<String, Object?>) Season.fromJson(s),
  ];

  (SeasonView, Wallet) _seasonWallet(Map<String, Object?> j) => (
    SeasonView.fromJson(j),
    Wallet.fromJson(j['wallet']),
  );

  /// 422 `insufficient_funds | already_owned`.
  Future<(SeasonView, Wallet)> buySeasonPremium(String idempotencyKey) async =>
      _seasonWallet(
        await _call('POST', '/season/pass/premium', {
          'idempotencyKey': idempotencyKey,
        }),
      );

  /// 422 `no_reward | not_reached | premium_required | already_claimed`.
  Future<(SeasonView, Wallet)> claimPassReward(
    int level,
    PassTrack track,
  ) async => _seasonWallet(
    await _call('POST', '/season/pass/claim', {
      'level': level,
      'track': track.name,
    }),
  );

  Future<(SeasonView, Wallet)> claimAllPassRewards() async =>
      _seasonWallet(await _call('POST', '/season/pass/claim-all'));

  /// The latest finished season (or [number]); 404 when there is none.
  Future<SeasonSummary> seasonSummary([int? number]) async =>
      SeasonSummary.fromJson(
        await _call(
          'GET',
          '/season/summary${number == null ? '' : '/$number'}',
        ),
      );

  Future<Leaderboard> leaderboard(
    Variant variant,
    LeaderboardScope scope, {
    int? season,
  }) async {
    final params = {
      'variant': variant.name,
      'scope': scope.name,
      if (season != null) 'season': '$season',
    };
    return Leaderboard.fromJson(
      await _call('GET', '/leaderboard?${Uri(queryParameters: params).query}'),
    );
  }

  Future<PuzzleBatch> nextPuzzle({Variant? variant}) async =>
      PuzzleBatch.fromJson(
        await _call(
          'GET',
          '/puzzles/next${variant == null ? '' : '?variant=${variant.name}'}',
        ),
      );

  Future<PuzzleBatch> dailyPuzzle() async =>
      PuzzleBatch.fromJson(await _call('GET', '/puzzles/daily'));

  /// [board] is the position after my moves (PuzzleBoard JSON). 422
  /// `bad_board | bad_attempt | finished`.
  Future<AttemptResult> attemptPuzzle(
    String id,
    int attempt,
    Map<String, Object?> board, {
    String? moves,
  }) async => AttemptResult.fromJson(
    await _call('POST', '/puzzles/$id/attempt', {
      'attempt': attempt,
      'board': board,
      if (moves != null) 'moves': moves,
    }),
  );

  Future<AttemptResult> revealPuzzle(String id) async =>
      AttemptResult.fromJson(await _call('POST', '/puzzles/$id/reveal'));

  // ---- Phase 7: notifications (docs/api/notifications.md) --------------

  /// The newest 50 rows, or only those after [after] (polling).
  Future<InboxPage> notifications({int? after}) async => InboxPage.fromJson(
    await _call('GET', '/notifications${after == null ? '' : '?after=$after'}'),
  );

  /// Marks [ids] (or everything with [all]) read; returns the unread count.
  Future<int> markNotificationsRead({List<int>? ids, bool all = false}) async =>
      ((await _call('POST', '/notifications/read', {
                if (all) 'all': true else 'ids': ids ?? const <int>[],
              }))['unread']
              as num?)
          ?.toInt() ??
      0;

  Future<int> deleteNotification(int id) async =>
      ((await _call('DELETE', '/notifications/$id'))['unread'] as num?)
          ?.toInt() ??
      0;

  Future<NotificationSettings> notificationSettings() async =>
      NotificationSettings.fromJson(
        (await _call('GET', '/me/notification-settings'))['settings']!
            as Map<String, Object?>,
      );

  /// Partial update: `push`, `quietHours{enabled,start,end}`,
  /// `categories{key: bool}`, `utcOffset` (minutes).
  Future<NotificationSettings> updateNotificationSettings(
    Map<String, Object?> fields,
  ) async => NotificationSettings.fromJson(
    (await _call('PUT', '/me/notification-settings', fields))['settings']!
        as Map<String, Object?>,
  );

  /// Registers an FCM token for this account (`android` | `ios`).
  Future<void> registerDevice(
    String platform,
    String token, {
    String? locale,
    int? utcOffset,
  }) => _call('POST', '/me/devices', {
    'platform': platform,
    'token': token,
    if (locale != null) 'locale': locale,
    if (utcOffset != null) 'utcOffset': utcOffset,
  });

  Future<void> unregisterDevice(String token) =>
      _call('DELETE', '/me/devices', {'token': token});
}
