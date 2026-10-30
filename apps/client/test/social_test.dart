import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/clans/clan_home_screen.dart';
import 'package:nard_client/clans/clan_leaderboard_screen.dart';
import 'package:nard_client/clans/clan_members_screen.dart';
import 'package:nard_client/clans/clan_models.dart';
import 'package:nard_client/clans/clan_profile_screen.dart';
import 'package:nard_client/clans/clan_rules.dart';
import 'package:nard_client/clans/clan_search_screen.dart';
import 'package:nard_client/clans/create_clan_screen.dart';
import 'package:nard_client/clans/emblem_builder_screen.dart';
import 'package:nard_client/clans/emblem_catalog.dart';
import 'package:nard_client/cosmetics/cosmetics_cache.dart';
import 'package:nard_client/cosmetics/cosmetics_providers.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/social/add_friend_screen.dart';
import 'package:nard_client/social/emotes.dart';
import 'package:nard_client/social/friends_screen.dart';
import 'package:nard_client/social/player_menu.dart';
import 'package:nard_client/social/room_screen.dart';
import 'package:nard_client/social/social_models.dart';
import 'package:nard_client/social/social_socket.dart';
import 'package:nard_client/store/store_models.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_client/ui/social.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import 'store_fakes.dart';

PublicUser _user(
  String id,
  String name, {
  bool online = false,
  int rating = 1800,
  ClanBadge? clan,
}) => PublicUser(
  id: id,
  name: name,
  online: online,
  ratings: {'shortNard': rating},
  clan: clan,
);

const _clanBadge = ClanBadge(
  id: '7',
  tag: 'QZR',
  emblem: Emblem(shape: 'shield', color: 'garnet'),
  name: 'Qızıl Zər',
  role: ClanRole.elder,
);

/// Friends, search, clans and chat in memory on top of the store fake.
class SocialFakeApi extends FakeApi {
  SocialFakeApi() : super(wallet: const Wallet(coins: 3450, gems: 0));

  var overview = FriendsOverview(
    friendCode: 'K7M2PQ9X',
    friends: [
      FriendEntry(requestId: 1, user: _user('2', 'Nigar_88', online: true)),
      FriendEntry(requestId: 2, user: _user('3', 'Rauf')),
    ],
    incoming: [FriendEntry(requestId: 3, user: _user('4', 'Kerem_TR'))],
    challenges: [
      Challenge(
        id: 1,
        from: _user('2', 'Nigar_88', online: true),
        code: 'NRD482',
        variant: Variant.longNard,
        matchLength: 5,
      ),
    ],
  );
  final requests = <String>[];

  @override
  Future<FriendsOverview> friends() async => overview;

  @override
  Future<FriendRequestStatus> requestFriend({
    String? code,
    String? userId,
  }) async {
    requests.add(code ?? userId!);
    if (code == 'AAAAAAAA') throw const ApiException(404, 'not_found');
    return FriendRequestStatus.requested;
  }

  @override
  Future<void> acceptFriend(int requestId) async {
    calls.add('accept:$requestId');
    final r = overview.incoming.firstWhere((e) => e.requestId == requestId);
    overview = FriendsOverview(
      friendCode: overview.friendCode,
      friends: [...overview.friends, r],
      challenges: overview.challenges,
    );
  }

  @override
  Future<List<PublicUser>> searchUsers(String query) async {
    calls.add('search:$query');
    return [
      _user('9', 'Nigar_88', rating: 1990, clan: _clanBadge),
      _user('10', 'Nigaris'),
    ].where((u) => u.name.toLowerCase().startsWith(query)).toList();
  }

  final blocked = <PublicUser>[];

  @override
  Future<List<PublicUser>> blocks() async => [...blocked];

  @override
  Future<void> block(String userId) async {
    calls.add('block:$userId');
    blocked.add(_user(userId, 'Kerem_TR'));
  }

  @override
  Future<String> report(
    String userId,
    ReportReason reason, {
    String? matchId,
    String? note,
  }) async {
    calls.add('report:$userId:${reason.name}:${note ?? ''}');
    return 'R-000001';
  }

  @override
  Future<(bool, bool)> tagAvailable(String tag) async => (true, tag != 'XQR');

  @override
  Future<ClanLeaderboard> clanLeaderboard() async => ClanLeaderboard(
    entries: [
      for (var i = 1; i <= 6; i++)
        LeaderboardEntry(
          rank: i,
          clan: ClanSummary(id: '$i', name: 'Klan $i', tag: 'KL$i'),
          points: 60000 - i * 3000,
        ),
    ],
    myRank: 14,
    myPoints: 12000,
    myClan: _clanBadge,
  );

  @override
  Future<List<ClanInvite>> clanInvites() async => const [];

  @override
  Future<List<ClanSummary>> clans({
    String? query,
    String? language,
    JoinPolicy? policy,
    int? maxMinRating,
  }) async => const [
    ClanSummary(
      id: '7',
      name: 'Qızıl Zər',
      tag: 'QZR',
      level: 14,
      memberCount: 42,
      rating: 2140,
    ),
    ClanSummary(
      id: '8',
      name: 'Xəzər Qartalları',
      tag: 'XQR',
      emblem: Emblem(shape: 'octagon', color: 'indigo'),
      level: 12,
      memberCount: 50,
      rating: 2085,
    ),
    ClanSummary(
      id: '9',
      name: 'Abşeron Altılığı',
      tag: 'ABS',
      emblem: Emblem(shape: 'circle', color: 'purple'),
      joinPolicy: JoinPolicy.open,
      level: 7,
      memberCount: 22,
    ),
  ];

  @override
  Future<ClanDetail> clan(String id) async => ClanDetail(
    summary: const ClanSummary(
      id: '7',
      name: 'Qızıl Zər',
      tag: 'QZR',
      level: 14,
      memberCount: 3,
      rating: 2140,
    ),
    description: 'Bakıdan ciddi nərd oyunçuları.',
    onlineCount: 2,
    myStatus: ClanStatus.member,
    myRole: ClanRole.elder,
    chest: const ClanChest(coins: 7400, target: 10000, myDonated: 500),
    members: [
      ClanMember(user: _user('5', 'Rauf', rating: 2210), role: ClanRole.leader),
      ClanMember(user: _user('1', 'Elvin'), role: ClanRole.elder),
      ClanMember(
        user: _user('6', 'Aysel_A'),
        role: ClanRole.member,
        weeklyDonated: 500,
      ),
    ],
  );

  @override
  Future<List<ClanMessage>> clanMessages(String id, {int? after}) async {
    if (after != null) return const [];
    return const [
      ClanMessage(
        id: 1,
        system: true,
        event: 'war_win',
        data: {'name': 'Rauf', 'points': 3},
      ),
      ClanMessage(
        id: 2,
        system: false,
        author: MessageAuthor(id: '5', name: 'Rauf'),
        text: 'Bu axşam döyüş var',
      ),
      ClanMessage(
        id: 3,
        system: false,
        author: MessageAuthor(id: '1', name: 'Elvin'),
        text: 'Hazıram',
      ),
    ];
  }

  @override
  Future<ClanMessage> postClanMessage(String id, String text) async {
    calls.add('post:$text');
    return ClanMessage(
      id: 4,
      system: false,
      author: const MessageAuthor(id: '1', name: 'Elvin'),
      text: text,
    );
  }
}

/// Records socket intents instead of opening a WebSocket.
class FakeSocialSocket extends SocialSocket {
  FakeSocialSocket([this.initial = const RoomState()]);

  final RoomState initial;
  final sent = <String>[];

  @override
  RoomState build() => initial;

  @override
  void queryPresence(List<String> userIds) => sent.add('presence');

  @override
  void joinRoom(String code, {Variant? variant, int? matchLength}) =>
      sent.add('join:$code');

  @override
  void createRoom(Variant variant, int matchLength, {PublicUser? invite}) =>
      sent.add('create:${invite?.id}');

  @override
  bool sendEmote(String id) {
    if (!Emotes.isValid(id)) return false;
    sent.add(id);
    return true;
  }
}

class _ClanMember extends AccountNotifier {
  @override
  Future<Account?> build() async =>
      const Account(id: '1', name: 'Elvin', guest: false, clan: _clanBadge);
}

Future<FakeSocialSocket> _pump(
  WidgetTester tester,
  Widget screen,
  SocialFakeApi api, {
  bool inClan = false,
  RoomState room = const RoomState(),
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final socket = FakeSocialSocket(room);
  final overrides = <Override>[
    accountProvider.overrideWith(inClan ? _ClanMember.new : SignedIn.new),
    apiClientProvider.overrideWithValue(api),
    cosmeticsCacheProvider.overrideWithValue(MemoryCosmeticsCache()),
    settingsProvider.overrideWith(MemorySettings.new),
    socialSocketProvider.overrideWith(() => socket),
  ];
  // Pushed routes land on a placeholder naming the location.
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => Scaffold(body: screen))],
    errorBuilder: (_, s) => Scaffold(body: Text('route:${s.uri}')),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
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
  return socket;
}

void main() {
  group('friends (6.1, 6.2)', () {
    testWidgets('list, presence order, accept a request, join a challenge', (
      tester,
    ) async {
      final api = SocialFakeApi();
      final socket = await _pump(tester, const FriendsScreen(), api);
      expect(tester.takeException(), isNull);
      expect(find.text('Dostlar'), findsOneWidget);
      expect(find.text('SORĞULAR'), findsOneWidget);
      expect(find.text('ÇAĞIRIŞLAR'), findsOneWidget);
      expect(find.text('Kerem_TR'), findsOneWidget);
      // Online first: Nigar (online) is above Rauf (offline).
      final nigar = tester.getTopLeft(find.text('Nigar_88').last).dy;
      final rauf = tester.getTopLeft(find.text('Rauf')).dy;
      expect(nigar, lessThan(rauf));
      expect(find.text('Onlayn'), findsOneWidget);
      expect(find.text('Oflayn'), findsOneWidget);
      // Presence was asked over the socket.
      expect(socket.sent, contains('presence'));

      await tester.tap(find.text('Qəbul et'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.calls, contains('accept:3'));
      expect(find.text('SORĞULAR'), findsNothing);
      expect(find.text('Kerem_TR'), findsOneWidget);

      await tester.tap(find.text('Qoşul'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(socket.sent, contains('join:NRD482'));
      expect(find.text('route:/room/join?code=NRD482'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('search adds by name; the code field sends the code', (
      tester,
    ) async {
      final api = SocialFakeApi();
      await _pump(tester, const AddFriendScreen(), api);
      expect(find.text('K7M2PQ9X'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'ni');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Ən azı 3 hərf yaz'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'nig');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(api.calls, contains('search:nig'));
      expect(find.text('Nigaris'), findsOneWidget);
      // Meta shows rank · rating · clan tag.
      expect(find.textContaining('[QZR]'), findsOneWidget);

      await tester.tap(find.text('Əlavə et').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.requests, ['9']);
      expect(find.text('Göndərildi'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'aaaaaaaa');
      await tester.tap(find.text('Göndər'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.requests.last, 'AAAAAAAA');
      expect(find.text('Oyunçu tapılmadı'), findsWidgets);
      await closeScreen(tester);
    });

    test('presence: in game beats online; offline last', () {
      final a = _user('a', 'Zaur', online: true);
      final b = _user('b', 'Anar');
      final c = _user('c', 'Bəxtiyar');
      final matches = {'b': 'm1'};
      expect(presenceOf(b, matches), Presence.inGame);
      expect(presenceOf(a, matches), Presence.online);
      expect(presenceOf(c, matches), Presence.offline);
      expect(sortByPresence([a, b, c], matches).map((u) => u.id), [
        'b',
        'a',
        'c',
      ]);
    });
  });

  group('emblems (5.3)', () {
    test('catalogue ids match the API config', () {
      expect(EmblemCatalog.shapes.keys.toList(), [
        'shield',
        'hexagon',
        'octagon',
        'circle',
        'diamond',
        'banner',
        'star',
        'arch',
      ]);
      expect(EmblemCatalog.colors.keys.toSet(), {
        'garnet',
        'indigo',
        'emerald',
        'brass',
        'purple',
        'slate',
        'ivory',
        'blue',
        'walnut',
      });
      expect(EmblemCatalog.symbols, [
        'diamond',
        'diamond_dot',
        'circle',
        'square',
        'initials',
      ]);
      expect(EmblemCatalog.patterns, ['none', 'lattice']);
    });

    test('every shape stays inside its box and every emblem paints', () {
      for (final shape in EmblemCatalog.shapes.keys) {
        const size = Size(96, 110);
        final bounds = EmblemCatalog.path(shape, size).getBounds();
        expect(bounds.width, greaterThan(0), reason: shape);
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(size.width + .001));
        expect(bounds.bottom, lessThanOrEqualTo(size.height + .001));
        for (final symbol in EmblemCatalog.symbols) {
          for (final width in const [30.0, 96.0, 170.0]) {
            final recorder = ui.PictureRecorder();
            EmblemPainter(
              emblem: Emblem(
                shape: shape,
                symbol: symbol,
                color: 'ivory',
                pattern: 'lattice',
              ),
              initials: symbol == 'initials' ? 'QZ' : null,
              accentHi: const Color(0xFFE8C468),
              text: const Color(0xFFF3EBDD),
              dark: const Color(0xFF2B1D14),
            ).paint(
              Canvas(recorder),
              Size(width, width / EmblemCatalog.aspect(shape)),
            );
            recorder.endRecording().dispose();
          }
        }
      }
      expect(EmblemCatalog.aspect('shield'), closeTo(1 / 1.15, 1e-9));
      expect(EmblemCatalog.aspect('octagon'), 1);
      expect(clanInitials('Qızıl Zər'), 'QZ');
      expect(clanInitials('Abşeron'), 'AB');
    });

    test('emblem JSON round-trips; unknown values fall back', () {
      const e = Emblem(
        shape: 'star',
        symbol: 'circle',
        color: 'emerald',
        pattern: 'lattice',
      );
      expect(Emblem.fromJson(e.toJson()), e);
      expect(Emblem.fromJson(null), const Emblem());
      expect(EmblemCatalog.colorOf('nope'), EmblemCatalog.colorOf('garnet'));
    });
  });

  group('clan rules (19.1, ADR-036)', () {
    test('create validation: name, tag, price', () {
      expect(ClanRules.validName('Qızıl Zər'), isTrue);
      expect(ClanRules.validName('  Ab  '), isFalse);
      expect(ClanRules.validName('x' * 25), isFalse);
      expect(ClanRules.validName('-Bad'), isFalse);
      expect(
        ClanRules.normalizeName('  Gəncə   Nərdçiləri '),
        'Gəncə Nərdçiləri',
      );
      expect(ClanRules.validTag('qzr'), isTrue);
      expect(ClanRules.validTag('XQ'), isFalse);
      expect(ClanRules.validTag('ŞKU'), isFalse);
      expect(ClanRules.validTag('A65'), isFalse);
      expect(ClanRules.cleanTag('a6b-cdef'), 'ABCDE');
      const draft = ClanDraft(name: 'Qızıl Zər', tag: 'qzr');
      expect(ClanRules.canContinue(draft, tagAvailable: true), isTrue);
      expect(ClanRules.canContinue(draft, tagAvailable: false), isFalse);
      expect(ClanRules.canContinue(draft, tagAvailable: null), isFalse);
      expect(draft.toJson()['tag'], 'QZR');
      expect(draft.toJson()['minRating'], isNull);
      expect(draft.toJson().containsKey('description'), isFalse);
      expect(ClanRules.canAfford(3000), isTrue);
      expect(ClanRules.canAfford(2999), isFalse);
    });

    test('role permissions: strictly below, leader transfers', () {
      const r = ClanRole.values;
      expect(r.map((x) => x.api), ['member', 'elder', 'co_leader', 'leader']);
      expect(
        ClanPermissions.assignableRoles(ClanRole.leader, ClanRole.member),
        [ClanRole.elder, ClanRole.coLeader],
      );
      expect(
        ClanPermissions.assignableRoles(ClanRole.coLeader, ClanRole.elder),
        [ClanRole.member],
      );
      expect(
        ClanPermissions.assignableRoles(ClanRole.coLeader, ClanRole.coLeader),
        isEmpty,
      );
      expect(
        ClanPermissions.assignableRoles(ClanRole.elder, ClanRole.member),
        isEmpty,
      );
      expect(ClanPermissions.canKick(ClanRole.elder, ClanRole.member), isTrue);
      expect(ClanPermissions.canKick(ClanRole.elder, ClanRole.elder), isFalse);
      expect(
        ClanPermissions.canKick(ClanRole.member, ClanRole.member),
        isFalse,
      );
      expect(ClanPermissions.canTransfer(ClanRole.leader), isTrue);
      expect(ClanPermissions.canTransfer(ClanRole.coLeader), isFalse);
      expect(ClanPermissions.canDeclineRequest(ClanRole.elder), isFalse);
      expect(ClanPermissions.canAcceptRequest(ClanRole.elder), isTrue);
      expect(ClanPermissions.canEdit(ClanRole.coLeader), isTrue);
      expect(ClanPermissions.canRename(ClanRole.coLeader), isFalse);
      expect(
        ClanPermissions.canDeleteMessage(ClanRole.member, own: true),
        isTrue,
      );
      expect(
        ClanPermissions.canDeleteMessage(ClanRole.member, own: false),
        isFalse,
      );
      expect(
        ClanPermissions.canDeleteMessage(ClanRole.elder, own: false),
        isTrue,
      );
      expect(
        ClanPermissions.mustTransferBeforeLeaving(ClanRole.leader, 2),
        isTrue,
      );
      expect(
        ClanPermissions.mustTransferBeforeLeaving(ClanRole.leader, 1),
        isFalse,
      );
    });
  });

  group('emotes (2.7)', () {
    testWidgets('the wheel and the chips send protocol ids only', (
      tester,
    ) async {
      final sent = <String>[];
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: NardTheme.build(NardColors.defaultTheme),
          locale: const Locale('az'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: EmoteWheelOverlay(onSend: sent.add, onClose: () {}),
          ),
        ),
      );
      final l = await AppLocalizations.delegate.load(const Locale('az'));
      for (final id in wheelEmotes) {
        await tester.tap(find.bySemanticsLabel(emoteText(l, id)).first);
        await tester.pump();
      }
      for (final id in quickPhrases) {
        await tester.tap(find.text(emoteText(l, id)));
        await tester.pump();
      }
      expect(sent, [...wheelEmotes, ...quickPhrases]);
      expect(sent.every(Emotes.isValid), isTrue);
      // Every displayed id has a label (no raw ids on screen).
      for (final id in [...Emotes.emotes, ...Emotes.phrases]) {
        expect(emoteText(l, id), isNot(id));
      }
      semantics.dispose();
    });

    test('free text is never sent', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final socket = container.read(socialSocketProvider.notifier);
      expect(socket.sendEmote('Salam, necəsən?'), isFalse);
      expect(socket.sendEmote(''), isFalse);
    });
  });

  group('render 390×844', () {
    testWidgets('clan search (5.1)', (tester) async {
      final api = SocialFakeApi();
      await _pump(tester, const ClanSearch(), api);
      expect(tester.takeException(), isNull);
      expect(find.text('Klanlar'), findsOneWidget);
      expect(find.text('[QZR]'), findsOneWidget);
      expect(find.text('Müraciət'), findsOneWidget);
      expect(find.text('Dolu'), findsOneWidget);
      expect(find.text('Qoşul'), findsOneWidget);
      expect(find.byType(ClanEmblem), findsNWidgets(3));
      await closeScreen(tester);
    });

    testWidgets('clan home chat (5.4): bubbles, system pill, send', (
      tester,
    ) async {
      final api = SocialFakeApi();
      await _pump(tester, const ClanHome(clanId: '7'), api, inClan: true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Qızıl Zər'), findsOneWidget);
      expect(find.text('2 onlayn'), findsOneWidget);
      expect(find.text('Həftəlik sandıq'), findsOneWidget);
      expect(find.text('7 400 / 10 000'), findsOneWidget);
      expect(find.text('Bu axşam döyüş var'), findsOneWidget);
      // My own message is labelled "Sən".
      expect(find.text('Sən'), findsOneWidget);
      expect(find.text('Rauf klan döyüşündə qalib gəldi · +3'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Salam hamıya');
      await tester.pump();
      final semantics = tester.ensureSemantics();
      await tester.tap(find.bySemanticsLabel('Göndər'));
      semantics.dispose();
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.calls, contains('post:Salam hamıya'));
      expect(find.text('Salam hamıya'), findsOneWidget);

      // Sandıq tab: donors and preset amounts.
      await tester.tap(find.text('Sandıq'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Aysel_A'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await closeScreen(tester);
    });

    testWidgets('PresenceAvatar and RoleBadge render', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            PresenceAvatar(
              name: 'Nigar',
              size: 42,
              presence: PresenceDot.inGame,
            ),
            RoleBadge(role: ClanRole.leader, label: 'Lider'),
            CodeCells(code: 'NRD482'),
          ],
        ),
        SocialFakeApi(),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Lider'), findsOneWidget);
      expect(find.text('N'), findsWidgets);
      await closeScreen(tester);
    });
  });

  group('screens render at 390×844 without overflow', () {
    testWidgets('6.3 room (waiting) and join by code', (tester) async {
      await _pump(
        tester,
        const RoomScreen(),
        SocialFakeApi(),
        room: RoomState(
          phase: RoomPhase.waiting,
          code: 'NRD482',
          expiresAt: DateTime.now().add(const Duration(minutes: 14)),
          variant: Variant.longNard,
          matchLength: 5,
          invited: _user('2', 'Nigar_88'),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('OTAQ KODU'), findsOneWidget);
      expect(find.text('Dost gözlənilir…'), findsOneWidget);
      expect(find.text('Uzun nərd'), findsOneWidget);
      expect(find.text('Təsir etmir'), findsOneWidget);
      await closeScreen(tester);

      final socket = await _pump(
        tester,
        const JoinRoomScreen(code: 'nrd482'),
        SocialFakeApi(),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Qoşul'));
      await tester.pump();
      expect(socket.sent, ['join:NRD482']);
      await closeScreen(tester);
    });

    testWidgets('14.2 report: reason, note, also block → 14.4', (tester) async {
      final api = SocialFakeApi();
      await _pump(
        tester,
        const ReportScreen(
          args: ReportArgs(
            player: PlayerRef(id: '4', name: 'Kerem_TR'),
            matchId: 'm1',
          ),
        ),
        api,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Şikayət: Kerem_TR'), findsOneWidget);
      await tester.tap(find.text('Kömək proqramı istifadəsi'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'zərlər şübhəlidir');
      await tester.tap(find.text('Şikayəti göndər'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(api.calls, contains('report:4:cheating:zərlər şübhəlidir'));
      expect(api.calls, contains('block:4'));
      await closeScreen(tester);

      await _pump(
        tester,
        const ReportSentScreen(name: 'Kerem_TR', blocked: true),
        api,
      );
      expect(find.text('Şikayət göndərildi'), findsOneWidget);
      expect(find.textContaining('Kerem_TR bloklandı.'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('19.1 → 19.2 create clan', (tester) async {
      await _pump(tester, const CreateClanScreen(), SocialFakeApi());
      expect(tester.takeException(), isNull);
      expect(find.text('1 / 2'), findsOneWidget);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Şirvan Nərdçiləri');
      await tester.enterText(fields.at(1), 'srv1');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('Boşdur'), findsOneWidget);
      await tester.tap(find.text('Davam et'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('Müraciət ilə'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Balans: 3 450 → 450'), findsOneWidget);
      expect(find.text('3 000'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await closeScreen(tester);
    });

    testWidgets('5.2 profile, 5.5 members, 5.7 ranking, 5.3 emblem', (
      tester,
    ) async {
      final api = SocialFakeApi();
      await _pump(tester, const ClanProfileScreen(clanId: '7'), api);
      expect(tester.takeException(), isNull);
      expect(find.text('TƏLƏBLƏR'), findsOneWidget);
      expect(find.text('Klana keç'), findsOneWidget);
      await closeScreen(tester);

      await _pump(
        tester,
        const ClanMembersScreen(clanId: '7'),
        api,
        inClan: true,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Elvin (sən)'), findsOneWidget);
      expect(find.text('Lider'), findsOneWidget);
      // An elder may kick a member, not change roles.
      await tester.tap(find.text('Aysel_A'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Klandan çıxar'), findsOneWidget);
      expect(find.text('Müavin et'), findsNothing);
      await closeScreen(tester);

      await _pump(tester, const ClanLeaderboardScreen(), api);
      expect(tester.takeException(), isNull);
      expect(find.text('Klan 1'), findsOneWidget);
      expect(find.text('Sənin klanın · #14'), findsOneWidget);
      await closeScreen(tester);

      await _pump(tester, const EmblemBuilderScreen(), api);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Simvol'));
      await tester.pump();
      await tester.tap(find.text('Naxış'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await closeScreen(tester);
    });
  });
}
