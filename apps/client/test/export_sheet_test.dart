import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/screens/online/account_sheets.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';

class _Store extends CredentialStore {
  @override
  Future<String?> token() async => 'token';

  @override
  Future<void> saveToken(String? token) async {}
}

class _Api extends ApiClient {
  _Api(this.email) : super('http://test');

  final String? email;
  int exports = 0;

  @override
  Future<Account> me() async =>
      Account(id: '1', name: 'Aysel', guest: email == null, email: email);

  @override
  Future<String> requestExport() async {
    exports++;
    return email!;
  }
}

/// 15.2 export: an e-mailed ZIP; guests link an e-mail first (QUESTIONS #17).
void main() {
  Future<(_Api, List<String>)> open(WidgetTester tester, String? email) async {
    final api = _Api(email);
    final pushed = <String>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () => showExportSheet(context),
                  child: const Text('open'),
                ),
              ),
        ),
        GoRoute(
          path: '/signin/email',
          builder: (_, _) {
            pushed.add('/signin/email');
            return const Scaffold(body: Text('email screen'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          credentialStoreProvider.overrideWithValue(_Store()),
        ],
        child: MaterialApp.router(
          theme: NardTheme.build(NardColors.defaultTheme),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return (api, pushed);
  }

  testWidgets('the ZIP is e-mailed to the account address', (tester) async {
    final (api, _) = await open(tester, 'aysel@example.com');
    expect(find.textContaining('aysel@example.com'), findsOneWidget);
    expect(find.text('ZIP · JSON'), findsOneWidget);
    await tester.tap(find.text('Start export'));
    await tester.pumpAndSettle();
    expect(api.exports, 1);
    expect(find.text('Sent to aysel@example.com'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Start export'), findsNothing);
  });

  testWidgets('a guest is asked to link an e-mail first', (tester) async {
    final (api, pushed) = await open(tester, null);
    expect(find.text('Start export'), findsNothing);
    await tester.tap(find.text('Link e-mail'));
    await tester.pumpAndSettle();
    expect(pushed, ['/signin/email']);
    expect(api.exports, 0);
  });
}
