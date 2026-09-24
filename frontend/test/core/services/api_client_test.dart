import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wisp_mental_health/core/services/api_client.dart';
import 'package:wisp_mental_health/features/auth/domain/app_user.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  const baseUrl = 'http://api.test/api';
  const user = AppUser(uid: 'u1', email: 'me@example.com');

  late List<http.Request> requests;

  ApiClient client({required http.Response Function(http.Request) respond, FakeAuthRepository? auth}) {
    requests = [];
    return ApiClient(
      authRepo: auth ?? FakeAuthRepository(user: user),
      baseUrl: baseUrl,
      client: MockClient((request) async {
        requests.add(request);
        return respond(request);
      }),
    );
  }

  http.Response json(Object body, {int status = 200}) =>
      http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

  group('authentication headers', () {
    test('sends the bearer token and JSON headers', () async {
      final api = client(respond: (_) => json({'message': 'ok', 'uid': 'u1'}));

      await api.getProtectedData();

      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), '$baseUrl/wisps/protected');
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(request.headers['Accept'], 'application/json');
    });

    test('refuses to call the API when nobody is signed in', () async {
      final api = client(respond: (_) => json({}), auth: FakeAuthRepository());

      await expectLater(api.getProtectedData(), throwsA(isA<ApiException>()));
      expect(requests, isEmpty);
    });
  });

  group('saveWisp', () {
    test('posts a JSON body and returns the created wisp', () async {
      final api = client(
        respond: (request) => json({
          'message': 'Wisp saved successfully!',
          'wispId': 'w1',
          'wisp': {'id': 'w1', 'mood': 'Zen', 'reflection': 'Calm', 'createdAt': '2026-09-11T10:00:00.000Z'},
        }, status: 201),
      );

      final wisp = await api.saveWisp(mood: 'Zen', reflection: 'Calm');

      expect(requests.single.method, 'POST');
      expect(jsonDecode(requests.single.body), {'mood': 'Zen', 'reflection': 'Calm'});
      expect(wisp.id, 'w1');
      expect(wisp.createdAt, DateTime.utc(2026, 9, 11, 10).toLocal());
    });

    test('surfaces the server error message with its status code', () async {
      final api = client(respond: (_) => json({'error': 'Validation failed'}, status: 400));

      await expectLater(
        api.saveWisp(mood: '', reflection: ''),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Validation failed')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });

  group('fetchWisps', () {
    test('passes the limit and parses the list', () async {
      final api = client(
        respond: (_) => json({
          'wisps': [
            {'id': 'a', 'mood': 'Zen', 'reflection': 'one', 'createdAt': null},
            {'id': 'b', 'mood': 'Calm', 'reflection': 'two', 'createdAt': '2026-09-11T10:00:00.000Z'},
          ],
        }),
      );

      final wisps = await api.fetchWisps(limit: 5);

      expect(requests.single.url.queryParameters, {'limit': '5'});
      expect(wisps.map((w) => w.id), ['a', 'b']);
      expect(wisps.first.createdAt, isNull);
    });
  });

  group('failure handling', () {
    test('tolerates a non-JSON error body (e.g. an HTML page from a proxy)', () async {
      final api = client(respond: (_) => http.Response('<html>Bad Gateway</html>', 502));

      await expectLater(
        api.getProtectedData(),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Request failed (502)')),
      );
    });

    test('maps transport failures to a user-friendly message', () async {
      final api = client(respond: (_) => throw http.ClientException('Connection refused'));

      await expectLater(
        api.getProtectedData(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', isNull)
              .having((e) => e.message, 'message', contains('Could not reach')),
        ),
      );
    });

    test('marks 401 responses so callers can re-authenticate', () async {
      final api = client(respond: (_) => json({'error': 'Unauthorized: Invalid or expired token'}, status: 401));

      await expectLater(
        api.getProtectedData(),
        throwsA(isA<ApiException>().having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)),
      );
    });
  });
}
