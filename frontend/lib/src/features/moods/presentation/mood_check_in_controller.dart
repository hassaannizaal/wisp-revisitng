import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mood_repository.dart';
import '../domain/mood.dart';

@immutable
class MoodCheckInState {
  const MoodCheckInState({this.log, this.error});

  /// The check-in written by this screen session, if a state has been picked.
  final MoodLog? log;
  final String? error;

  Mood? get selected => log?.mood;

  MoodCheckInState copyWith({MoodLog? log, String? error}) => MoodCheckInState(log: log ?? this.log, error: error);
}

/// One screen session = one check-in. The first tap creates the log (the
/// spec writes on selection, not on Continue); a later tap corrects it in
/// place rather than logging twice.
class MoodCheckInController extends AutoDisposeNotifier<MoodCheckInState> {
  @override
  MoodCheckInState build() => const MoodCheckInState();

  Future<void> select(Mood mood) async {
    final repo = ref.read(moodRepositoryProvider);
    final current = state.log;
    if (current?.mood == mood) return;
    try {
      final log = current == null ? await repo.log(mood) : await repo.changeMood(current.id, mood);
      state = state.copyWith(log: log);
    } catch (e, stackTrace) {
      debugPrint('Mood check-in failed: $e\n$stackTrace');
      state = state.copyWith(error: "That didn't save. Try tapping it again.");
    }
  }
}

final moodCheckInControllerProvider = AutoDisposeNotifierProvider<MoodCheckInController, MoodCheckInState>(
  MoodCheckInController.new,
);

/// Today's check-in from the local store, for surfaces like Home.
final todayMoodProvider = FutureProvider.autoDispose<MoodLog?>((ref) {
  return ref.watch(moodRepositoryProvider).today();
});
