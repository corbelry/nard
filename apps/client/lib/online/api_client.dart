import 'dart:convert';

import 'package:http/http.dart' as http;

/// An API error with its machine code (e.g. `code_invalid`).
class ApiException implements Exception {
  const ApiException(this.status, this.code, [this.message = '']);

  final int status;
  final String code;
  final String message;

  /// No connection (status 0).
  bool get offline => status == 0;

  @override
  String toString() => 'ApiException($status, $code)';
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
  });

  final String id;
  final String name;
  final bool guest;
  final String? email;
  final String? country;
  final String locale;

  /// variant name → {rating, peak, matches, wins, tier}.
  final Map<String, RatingInfo> ratings;

  static Account fromJson(Map<String, Object?> j) {
    final ratings = j['ratings'];
    return Account(
      id: j['id']! as String,
      name: j['name']! as String,
      guest: j['guest']! as bool,
      email: j['email'] as String?,
      country: j['country'] as String?,
      locale: j['locale'] as String? ?? 'az',
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
    final http.Response res;
    try {
      res = await http.Response.fromStream(
        await _http.send(req).timeout(const Duration(seconds: 15)),
      );
    } on Object catch (e) {
      throw ApiException(0, 'offline', '$e');
    }
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    final json =
        decoded is Map<String, Object?> ? decoded : <String, Object?>{};
    if (res.statusCode >= 300) {
      throw ApiException(
        res.statusCode,
        json['code'] as String? ??
            (res.statusCode == 422 ? 'validation' : 'http_${res.statusCode}'),
        json['message'] as String? ?? '',
      );
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

  Future<void> logout() => _call('POST', '/auth/logout');

  Future<Account> me() async => Account.fromJson(
    (await _call('GET', '/me'))['user']! as Map<String, Object?>,
  );

  Future<Account> updateMe(Map<String, Object?> fields) async =>
      Account.fromJson(
        (await _call('PATCH', '/me', fields))['user']! as Map<String, Object?>,
      );

  Future<void> deleteMe() => _call('DELETE', '/me');

  Future<Map<String, Object?>> export() => _call('GET', '/me/export');

  Future<List<Map<String, Object?>>> matches({int limit = 30}) async =>
      ((await _call('GET', '/me/matches?limit=$limit'))['matches']! as List)
          .cast<Map<String, Object?>>();

  Future<Map<String, Object?>> match(String id) async =>
      (await _call('GET', '/me/matches/$id'))['match']! as Map<String, Object?>;

  /// A short-lived game-server ticket.
  Future<String> ticket() async =>
      (await _call('POST', '/game/ticket'))['ticket']! as String;
}
