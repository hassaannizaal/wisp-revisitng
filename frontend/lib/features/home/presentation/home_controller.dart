import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../wisps/domain/wisp.dart';

/// The signed-in user's most recent wisps, newest first.
final recentWispsProvider = AsyncNotifierProvider.autoDispose<RecentWispsController, List<Wisp>>(
  RecentWispsController.new,
);

class RecentWispsController extends AutoDisposeAsyncNotifier<List<Wisp>> {
  static const pageSize = 20;

  @override
  Future<List<Wisp>> build() {
    return ref.watch(apiClientProvider).fetchWisps(limit: pageSize);
  }

  /// Saves a wisp and shows it at the top of the list without a second
  /// round-trip. Errors propagate to the caller so the UI can report them.
  Future<Wisp> save({required String mood, required String reflection}) async {
    final saved = await ref.read(apiClientProvider).saveWisp(mood: mood, reflection: reflection);
    final current = state.valueOrNull ?? const <Wisp>[];
    state = AsyncData([saved, ...current].take(pageSize).toList(growable: false));
    return saved;
  }
}
