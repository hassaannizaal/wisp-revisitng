import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/audio_service.dart';
import 'splash_state.dart';

final splashControllerProvider = NotifierProvider<SplashController, SplashState>(() {
  return SplashController();
});

class SplashController extends Notifier<SplashState> {
  Timer? _timer;

  static const List<String> wellnessQuotes = [
    "You don't have to be okay all the time",
    "Healing is not linear",
    "Still here. Still trying. That counts",
    "Surviving is enough",
    "Small steps are still movement",
    "This moment will pass",
    "You've survived every hard day so far",
    "Right now is enough",
    "Be gentle with yourself",
    "You deserve your own kindness",
    "Progress, not perfection",
    "Breathe. You are still here",
    "Pause. You are allowed to pause",
    "One breath at a time",
    "The night always ends",
    "Low days are not lost days",
    "Darkness is not the destination",
    "You are not your worst thought",
    "You are not your diagnosis",
    "You are more than this moment",
  ];

  @override
  SplashState build() {
    ref.onDispose(() => _timer?.cancel());
    
    return SplashState(
      selectedQuote: wellnessQuotes[Random().nextInt(wellnessQuotes.length)],
    );
  }

  void handleInteraction() {
    if (!state.hasInteracted) {
      state = state.copyWith(hasInteracted: true);
      startFlow();
    }
  }

  Future<void> startFlow() async {
    // If Web, we wait for interaction which calls this method.
    // If not Web, we start immediately.
    if (kIsWeb && !state.hasInteracted) return;

    // Play sound (ignoring error for now)
    try {
      await AudioService().playLogoSound();
    } catch (_) {}

    // Phase 0: Logo (3s)
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(phase: 1);

    // Phase 1: Progress (simulate 0 to 99%)
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (state.progress < 0.99) {
        state = state.copyWith(progress: state.progress + 0.01);
      } else {
        timer.cancel();
        _nextPhases();
      }
    });
  }

  Future<void> _nextPhases() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(phase: 2);

    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(phase: 3);

    await Future.delayed(const Duration(seconds: 4));
    state = state.copyWith(isComplete: true);
  }
}
