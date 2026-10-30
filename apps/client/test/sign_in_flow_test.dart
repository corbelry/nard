import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/screens/online/code_screen.dart';
import 'package:nard_client/screens/online/email_screen.dart';
import 'package:nard_client/screens/online/sign_in_screen.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';

/// Keeps the token in memory instead of the platform keychain.
class _MemoryStore extends CredentialStore {
  String? saved;

  @override
  Future<String?> token() async => saved;

  @override
  Future<void> saveToken(String? token) async => saved = token;

  @override
  Future<String> deviceId() async => 'device-1';
}

/// The API as seen by the auth flow: guest works, providers are disabled,
/// e-mail codes are "123456".
class _FakeApi extends ApiClient {
  _FakeApi() : super('http://test');

  final calls = <String>[];

  Account _account({bool guest = false, String? email}) => Account(
    id: '1',
    name: guest ? 'Qonaq1' : 'Elvin',
    guest: guest,
    email: email,
  );

  @override
  Future<(String, Account)> guest(String deviceId, String locale) async {
    calls.add('guest:$deviceId:$locale');
    token = 'guest-token';
    return ('guest-token', _account(guest: true));
  }

  @override
  Future<(String, Account)> provider(String name, String idToken) async {
    calls.add('provider:$name');
    throw const ApiException(503, 'provider_disabled');
  }

  @override
  Future<void> emailStart(String email, String locale) async =>
      calls.add('start:$email');

  @override
  Future<(String, Account)> emailVerify(String email, String code) async {
    calls.add('verify:$code');
    if (code != '123456') throw const ApiException(422, 'code_invalid');
    token = 'mail-token';
    return ('mail-token', _account(email: email));
  }
}

class _Harness {
  _Harness() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, _) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      result = await context.push<bool>('/signin');
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
        ),
        GoRoute(path: '/signin', builder: (_, _) => const SignInScreen()),
        GoRoute(path: '/signin/email', builder: (_, _) => const EmailScreen()),
        GoRoute(
          path: '/signin/code',
          builder:
              (_, s) => CodeScreen(email: s.uri.queryParameters['email'] ?? ''),
        ),
      ],
    );
  }

  final api = _FakeApi();
  final store = _MemoryStore();
  late final GoRouter router;
  late final ProviderContainer container;
  bool? result;

  Future<void> pump(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        credentialStoreProvider.overrideWithValue(store),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: NardTheme.build(NardColors.defaultTheme),
          locale: const Locale('az'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Signed out at start.
    expect(await container.read(accountProvider.future), isNull);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  }
}

void main() {
  testWidgets('guest sign-in returns to the caller signed in', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    expect(find.text('Xoş gəldin'), findsOneWidget);
    await tester.tap(find.text('Qonaq kimi oyna'));
    await tester.pumpAndSettle();
    expect(h.result, isTrue);
    expect(h.api.calls, ['guest:device-1:az']);
    expect(h.store.saved, 'guest-token');
    expect(h.container.read(accountProvider).value?.guest, isTrue);
    await h.dispose(tester);
  });

  testWidgets('Apple sign-in is offered on iOS only (QUESTIONS #22)', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);
    expect(find.text('Apple ilə davam et'), findsNothing);
    expect(find.text('Google ilə davam et'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets(
    'Apple / Google show "not available yet" without crashing',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await tester.tap(find.text('Apple ilə davam et'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Bu giriş üsulu hələ hazır deyil. E-poçt ilə və ya qonaq kimi davam et.',
        ),
        findsOneWidget,
      );
      expect(h.result, isNull);
      expect(h.container.read(accountProvider).value, isNull);
      await h.dispose(tester);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('e-mail: invalid address blocks, wrong code errors, right '
      'code signs in and closes the whole flow', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    await tester.tap(find.text('E-poçt ilə davam et'));
    await tester.pumpAndSettle();
    expect(find.text('E-poçtunu yaz'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'elvin@');
    await tester.pump();
    await tester.tap(find.text('Kodu göndər'));
    await tester.pumpAndSettle();
    expect(h.api.calls, isEmpty);

    await tester.enterText(find.byType(TextField), 'elvin@mail.az');
    await tester.pump();
    await tester.tap(find.text('Kodu göndər'));
    await tester.pumpAndSettle();
    expect(h.api.calls, ['start:elvin@mail.az']);
    expect(find.text('Kodu yaz'), findsOneWidget);
    expect(find.textContaining('elvin@mail.az'), findsOneWidget);
    expect(find.textContaining('Kodu yenidən göndər ·'), findsOneWidget);

    // Wrong code: auto-submits on the 6th digit and shows the error.
    await tester.enterText(find.byType(TextField), '111111');
    await tester.pumpAndSettle();
    expect(h.api.calls.last, 'verify:111111');
    expect(find.text('Kod yanlışdır. Yenidən yoxla.'), findsOneWidget);
    expect(h.result, isNull);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    expect(h.api.calls.last, 'verify:123456');
    expect(h.result, isTrue);
    expect(find.text('open'), findsOneWidget);
    expect(h.container.read(accountProvider).value?.email, 'elvin@mail.az');
    expect(h.store.saved, 'mail-token');
    await h.dispose(tester);
  });

  testWidgets('resend unlocks after the cooldown', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    await tester.tap(find.text('E-poçt ilə davam et'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'elvin@mail.az');
    await tester.pump();
    await tester.tap(find.text('Kodu göndər'));
    await tester.pumpAndSettle();
    await tester.pump(CodeScreen.cooldown + const Duration(seconds: 1));
    await tester.tap(find.text('Kodu yenidən göndər'));
    await tester.pumpAndSettle();
    expect(h.api.calls.where((c) => c.startsWith('start:')), hasLength(2));
    expect(find.text('Yeni kod göndərildi'), findsOneWidget);
    await h.dispose(tester);
  });
}
