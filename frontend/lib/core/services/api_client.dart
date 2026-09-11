import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../src/features/auth/data/auth_repository.dart';
import '../../src/features/wisps/domain/wisp.dart';
import '../config/app_config.dart';

/// Raised for any failed call to the WISP API. [message] is always safe to show
/// to the user; [statusCode] is null when the request never reached the server.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    authRepo: ref.watch(authRepositoryProvider),
    baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
  );
});

/// Thin, typed HTTP client for the WISP backend.
///
/// Every request carries the current user's Firebase ID token, times out, and
/// maps failures to [ApiException] so callers never touch raw HTTP details.
class ApiClient {
  ApiClient({
    required AuthRepository authRepo,
    required String baseUrl,
    http.Client? client,
    Duration timeout = const Duration(seconds: 15),
  })  : _authRepo = authRepo,
        _baseUrl = baseUrl,
        _client = client ?? http.Client(),
        _timeout = timeout;

  final AuthRepository _authRepo;
  final String _baseUrl;
  final http.Client _client;
  final Duration _timeout;

  /// Verifies the token round-trip against the protected endpoint.
  Future<Map<String, dynamic>> getProtectedData() async {
    return _send('GET', '/wisps/protected');
  }

  Future<Wisp> saveWisp({required String mood, required String reflection}) async {
    final json = await _send('POST', '/wisps', body: {'mood': mood, 'reflection': reflection});
    return Wisp.fromJson(json['wisp'] as Map<String, dynamic>);
  }

  Future<List<Wisp>> fetchWisps({int limit = 20}) async {
    final json = await _send('GET', '/wisps', query: {'limit': '$limit'});
    return (json['wisps'] as List<dynamic>)
        .map((item) => Wisp.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request)).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond. Please try again.');
    } on http.ClientException {
      // package:http wraps socket/HTTP-level failures on every platform, including web.
      throw const ApiException('Could not reach the WISP server. Check your connection.');
    }

    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) return decoded;

    final serverMessage = decoded['error'];
    throw ApiException(
      serverMessage is String && serverMessage.isNotEmpty
          ? serverMessage
          : 'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    if (_authRepo.currentUser == null) {
      throw const ApiException('You need to be signed in to do that.');
    }
    final idToken = await _authRepo.getIdToken();
    if (idToken == null) {
      throw const ApiException('Your session has expired. Please sign in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  /// Tolerates non-JSON bodies (proxies and load balancers return HTML errors).
  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return const {};
    try {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}
