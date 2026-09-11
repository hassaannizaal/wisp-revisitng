import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wisp_mental_health/core/services/api_client.dart';
import 'package:wisp_mental_health/src/features/auth/domain/app_user.dart';
import 'package:wisp_mental_health/src/features/home/presentation/home_controller.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  const user = AppUser(uid: 'u1', email: 'me@example.com');

  ProviderContainer containerWith(http.Response Function(http.Request) respond) {
    final api = ApiClient(
      authRepo: FakeAuthRepository(user: user),
      baseUrl: 'http://api.test/api',
      client: MockClient((request) async => respond(request)),
    );
    final container = ProviderContainer(overrides: [apiClientProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    return container;
  }

  http.Response json(Object body, {int status = 200}) => http.Response(jsonEncode(body), status);

  test('loads the recent wisps on first read', () async {
    final container = containerWith((_) => json({
          'wisps': [
            {'id': 'a', 'mood': 'Zen', 'reflection': 'one', 'createdAt': null},
          ],
        }));

    final wisps = await container.read(recentWispsProvider.future);

    expect(wisps.map((w) => w.id), ['a']);
  });

  test('save() prepends the new wisp without refetching', () async {
    var posts = 0;
    final container = containerWith((request) {
      if (request.method == 'POST') {
        posts++;
        return json({
          'message': 'Wisp saved successfully!',
          'wispId': 'new',
          'wisp': {'id': 'new', 'mood': 'Zen', 'reflection': 'fresh', 'createdAt': null},
        }, status: 201);
      }
      return json({
        'wisps': [
          {'id': 'old', 'mood': 'Calm', 'reflection': 'one', 'createdAt': null},
        ],
      });
    });
    final sub = container.listen(recentWispsProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(recentWispsProvider.future);

    final saved = await container.read(recentWispsProvider.notifier).save(mood: 'Zen', reflection: 'fresh');

    expect(saved.id, 'new');
    expect(posts, 1);
    expect(container.read(recentWispsProvider).value!.map((w) => w.id), ['new', 'old']);
  });

  test('exposes list failures as an error state', () async {
    final container = containerWith((_) => json({'error': 'index missing'}, status: 503));
    final sub = container.listen(recentWispsProvider, (_, _) {});
    addTearDown(sub.close);

    await expectLater(container.read(recentWispsProvider.future), throwsA(isA<ApiException>()));
    expect(container.read(recentWispsProvider).hasError, isTrue);
  });
}
