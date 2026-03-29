import 'package:flutter/foundation.dart';

@immutable
class SplashState {
  final int phase;
  final double progress;
  final String selectedQuote;
  final bool hasInteracted;
  final bool isComplete;

  const SplashState({
    this.phase = 0,
    this.progress = 0.0,
    this.selectedQuote = '',
    this.hasInteracted = false,
    this.isComplete = false,
  });

  SplashState copyWith({
    int? phase,
    double? progress,
    String? selectedQuote,
    bool? hasInteracted,
    bool? isComplete,
  }) {
    return SplashState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      selectedQuote: selectedQuote ?? this.selectedQuote,
      hasInteracted: hasInteracted ?? this.hasInteracted,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SplashState &&
        other.phase == phase &&
        other.progress == progress &&
        other.selectedQuote == selectedQuote &&
        other.hasInteracted == hasInteracted &&
        other.isComplete == isComplete;
  }

  @override
  int get hashCode =>
      phase.hashCode ^
      progress.hashCode ^
      selectedQuote.hashCode ^
      hasInteracted.hashCode ^
      isComplete.hashCode;
}
