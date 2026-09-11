import 'package:flutter_test/flutter_test.dart';
import 'package:wisp_mental_health/src/features/wisps/domain/wisp.dart';

void main() {
  group('Wisp', () {
    test('round-trips through JSON', () {
      const wisp = Wisp(id: 'w1', mood: 'Zen', reflection: 'Calm');
      final json = wisp.toJson();

      expect(Wisp.fromJson({...json, 'createdAt': '2026-09-11T10:00:00.000Z'}).createdAt, isNotNull);
      expect(Wisp.fromJson(json), wisp);
    });

    test('treats a pending server timestamp as null', () {
      final wisp = Wisp.fromJson({'id': 'w1', 'mood': 'Zen', 'reflection': 'Calm', 'createdAt': null});
      expect(wisp.createdAt, isNull);
    });

    test('value equality', () {
      const a = Wisp(id: 'w1', mood: 'Zen', reflection: 'Calm');
      const b = Wisp(id: 'w1', mood: 'Zen', reflection: 'Calm');
      const c = Wisp(id: 'w2', mood: 'Zen', reflection: 'Calm');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
