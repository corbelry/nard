import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'online_config.dart';

/// Token and device id, kept in the platform keychain/keystore.
class CredentialStore {
  CredentialStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> token() => _storage.read(key: 'apiToken');
  Future<void> saveToken(String? token) =>
      token == null
          ? _storage.delete(key: 'apiToken')
          : _storage.write(key: 'apiToken', value: token);

  /// A random id created once per install (guest accounts, ADR-020).
  Future<String> deviceId() async {
    final existing = await _storage.read(key: 'deviceId');
    if (existing != null) return existing;
    final r = Random.secure();
    final id = List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
    await _storage.write(key: 'deviceId', value: id);
    return id;
  }
}

final credentialStoreProvider = Provider<CredentialStore>(
  (_) => CredentialStore(),
);

final apiClientProvider = Provider<ApiClient>(
  (_) => ApiClient(OnlineConfig.apiUrl),
);

/// Signed-in state. `null` = signed out; errors surface as AsyncError.
class AccountNotifier extends AsyncNotifier<Account?> {
  ApiClient get _api => ref.read(apiClientProvider);
  CredentialStore get _store => ref.read(credentialStoreProvider);

  @override
  Future<Account?> build() async {
    final token = await _store.token();
    if (token == null) return null;
    _api.token = token;
    try {
      return await _api.me();
    } on ApiException catch (e) {
      if (e.status == 401) {
        await _store.saveToken(null);
        _api.token = null;
        return null;
      }
      rethrow;
    }
  }

  Future<void> _signedIn((String, Account) result) async {
    await _store.saveToken(result.$1);
    state = AsyncData(result.$2);
  }

  Future<void> signInAsGuest(String locale) async =>
      _signedIn(await _api.guest(await _store.deviceId(), locale));

  Future<void> requestCode(String email, String locale) =>
      _api.emailStart(email, locale);

  /// Upgrades a signed-in guest, or signs in with the e-mail account.
  Future<void> verifyCode(String email, String code) async =>
      _signedIn(await _api.emailVerify(email, code));

  Future<void> rename(String name) async =>
      state = AsyncData(await _api.updateMe({'name': name}));

  Future<void> signOut() async {
    try {
      await _api.logout();
    } on ApiException {
      // Signing out locally is enough when offline.
    }
    await _store.saveToken(null);
    _api.token = null;
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    await _api.deleteMe();
    await _store.saveToken(null);
    _api.token = null;
    state = const AsyncData(null);
  }

  Future<void> refresh() async => state = AsyncData(await _api.me());
}

final accountProvider = AsyncNotifierProvider<AccountNotifier, Account?>(
  AccountNotifier.new,
);
