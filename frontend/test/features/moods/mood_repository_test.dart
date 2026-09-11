import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wisp_mental_health/core/services/api_client.dart';
import 'package:wisp_mental_health/core/storage/local_store.dart';
import 'package:wisp_mental_health/src/features/auth/domain/app_user.dart';
import 'package:wisp_mental_health/src/features/moods/data/mood_repository.dart';
import 'package:wisp_mental_health/src/features/moods/domain/mood.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  const user = AppUser(uid: 'u1', email: 'me@example.com');
  final now = DateTime(2026, 9, 11, 21, 4);

  late MemoryLocalStore store;
  late List<http.Request> requests;
  late bool offline;
  late Map<String, Map<String, dynamic>> server;

  /// A tiny stand-in for /api/moods that mirrors the real idempotency rules.
  http.Response handle(http.Request request) {
    requests.add(request);
    if (offline) throw http.ClientException('offline');
    final path = request.url.path;
    if (request.method == 'POST' && path.endsWith('/moods')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final existed = server.containsKey(body['id']);
      server.putIfAbsent(body['id'] as String, () => {...body});
      return http.Response(jsonEncode({'moodLog': server[body['id']]}), existed ? 200 : 201);
    }
    if (request.method == 'PATCH') {
      final id = path.split('/').last;
      server[id]!['mood'] = (jsonDecode(request.body) as Map)['mood'];
      return http.Response(jsonEncode({'moodLog': server[id]}), 200);
    }
    if (request.method == 'GET') {
      return http.Response(jsonEncode({'moods': server.values.toList()}), 200);
    }
    return http.Response('{"error":"unexpected"}', 500);
  }

  ApiClient api() => ApiClient(
    authRepo: FakeAuthRepository(user: user),
    baseUrl: 'http://api.test/api',
    client: MockClient((request) async => handle(request)),
  );

  MoodRepository repo({String uid = 'u1'}) => MoodRepository(store: store, api: api(), uid: uid, now: () => now);

  setUp(() {
    store = MemoryLocalStore();
    requests = [];
    offline = false;
    server = {};
  });

  test('a check-in is written locally first and pushed behind it', () async {
    final r = repo();
    final log = await r.log(Mood.okay);

    expect(log.sync, SyncState.pendingCreate);
    expect(log.loggedAt, now);
    expect((await r.all()).single.id, log.id, reason: 'readable locally before the network is involved');

    await r.sync();
    expect(requests.single.method, 'POST');
    expect((await r.all()).single.sync, SyncState.synced);
    expect((await r.today())?.mood, Mood.okay);
  });

  test('offline: the log stays pending and syncs on the next attempt without duplicating', () async {
    offline = true;
    final r = repo();
    final log = await r.log(Mood.low);
    await r.sync();
    expect((await r.all()).single.sync, SyncState.pendingCreate);
    expect(server, isEmpty);

    offline = false;
    requests = [];
    await r.sync();
    await r.sync(); // a second pass must be a no-op
    expect(server.keys, [log.id]);
    expect(requests.where((q) => q.method == 'POST').length, 1);
    expect((await r.all()).single.sync, SyncState.synced);
  });

  test('a corrected tap changes the same check-in instead of logging twice', () async {
    final r = repo();
    final first = await r.log(Mood.low);
    await r.sync();

    final changed = await r.changeMood(first.id, Mood.flat);
    expect(changed.sync, SyncState.pendingUpdate);
    await r.sync();

    expect((await r.all()).length, 1);
    expect(server[first.id]!['mood'], 'flat');
    expect(requests.map((q) => q.method), ['POST', 'PATCH']);
  });

  test('correcting a log the server has never seen is still a single create', () async {
    offline = true;
    final r = repo();
    final first = await r.log(Mood.low);
    final changed = await r.changeMood(first.id, Mood.good);
    expect(changed.sync, SyncState.pendingCreate);

    offline = false;
    requests = [];
    await r.sync();
    expect(requests.where((q) => q.method == 'POST').length, 1, reason: 'one check-in, one create');
    expect(server.keys, [first.id]);
    expect(server[first.id]!['mood'], 'good');
    expect((await r.all()).single.sync, SyncState.synced);
  });

  test('refresh merges server logs but never overwrites unsynced local edits', () async {
    server['remote-1'] = {'id': 'remote-1', 'mood': 'bright', 'loggedAt': '2026-09-10T08:00:00.000Z'};
    offline = true;
    final r = repo();
    final mine = await r.log(Mood.flat);

    offline = false;
    // Make the server disagree about the pending local log.
    server[mine.id] = {'id': mine.id, 'mood': 'okay', 'loggedAt': mine.loggedAt.toUtc().toIso8601String()};

    final merged = await r.refresh();
    expect(merged.map((l) => l.id), containsAll(['remote-1', mine.id]));
    expect(merged.firstWhere((l) => l.id == mine.id).mood, Mood.flat, reason: 'the local edit wins until acknowledged');
  });

  test('logs are keyed per user', () async {
    await repo().log(Mood.okay);
    expect(await repo(uid: 'someone-else').all(), isEmpty);
    expect(await repo().all(), hasLength(1));
  });
}
