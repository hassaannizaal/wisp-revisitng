import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wisp_mental_health/core/services/api_client.dart';
import 'package:wisp_mental_health/core/storage/local_store.dart';
import 'package:wisp_mental_health/core/theme/app_theme.dart';
import 'package:wisp_mental_health/src/features/auth/domain/app_user.dart';
import 'package:wisp_mental_health/src/features/moods/data/mood_repository.dart';
import 'package:wisp_mental_health/src/features/moods/domain/mood.dart';
import 'package:wisp_mental_health/src/features/moods/presentation/mood_check_in_screen.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  const user = AppUser(uid: 'u1', email: 'me@example.com');
  late MemoryLocalStore store;
  late List<http.Request> requests;
  late Map<String, Map<String, dynamic>> server;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    store = MemoryLocalStore();
    requests = [];
    server = {};
  });

  Future<void> pump(WidgetTester tester) async {
    final api = ApiClient(
      authRepo: FakeAuthRepository(user: user),
      baseUrl: 'http://api.test/api',
      client: MockClient((request) async {
        requests.add(request);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (request.method == 'PATCH') {
          final id = request.url.pathSegments.last;
          server[id]!['mood'] = body['mood'];
          return http.Response(jsonEncode({'moodLog': server[id]}), 200);
        }
        server[body['id'] as String] = body;
        return http.Response(jsonEncode({'moodLog': body}), 201);
      }),
    );
    final repo = MoodRepository(store: store, api: api, uid: user.uid);

    // A phone-height surface so every option row is laid out.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [moodRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(theme: AppTheme.dark, home: const MoodCheckInScreen()),
      ),
    );
  }

  testWidgets('shows five named states in low → bright order and no numbers', (tester) async {
    await pump(tester);

    final labels = Mood.values.map((m) => m.label).toList();
    expect(labels, ['Low', 'Flat', 'Okay', 'Good', 'Bright']);
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('How are you arriving today?'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+ ?/ ?10')), findsNothing);
    expect(find.text('Skip today'), findsOneWidget);
  });

  testWidgets('continue is disabled until a state is picked', (tester) async {
    await pump(tester);
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(button.onPressed, isNull);
  });

  testWidgets('tapping a state writes immediately, updates the heading and the CTA', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();

    expect(find.text('Noted. Anything behind it?'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Write about it'), findsOneWidget);

    final stored = await store.read('moods.u1.logs') as List;
    expect(stored.single['mood'], 'okay', reason: 'written on selection, not on Continue');
    expect(requests.where((r) => r.method == 'POST').length, 1);
  });

  testWidgets('a corrected tap keeps a single check-in', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flat'));
    await tester.pumpAndSettle();

    final stored = await store.read('moods.u1.logs') as List;
    expect(stored, hasLength(1));
    expect(stored.single['mood'], 'flat');
  });
}
