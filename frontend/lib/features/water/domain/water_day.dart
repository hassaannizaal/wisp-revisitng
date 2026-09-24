import 'package:flutter/foundation.dart';

import '../../../core/storage/local_first_repository.dart';

/// One row per user per day, updated in place — never one row per glass.
/// Spec: docs/screens/07-water.md
@immutable
class WaterDay implements Syncable {
  const WaterDay({required this.date, required this.glasses, this.sync = SyncState.synced});

  factory WaterDay.fromJson(Map<String, dynamic> json) => WaterDay(
    date: parseDate(json['loggedFor'] as String),
    glasses: json['glasses'] as int,
    sync: SyncState.values.byName(json['sync'] as String? ?? SyncState.synced.name),
  );

  /// The local calendar date this total belongs to.
  final DateTime date;
  final int glasses;
  @override
  final SyncState sync;

  /// The day is the identity: `2026-09-11`.
  @override
  String get id => formatDate(date);

  WaterDay copyWith({int? glasses, SyncState? sync}) =>
      WaterDay(date: date, glasses: glasses ?? this.glasses, sync: sync ?? this.sync);

  @override
  Map<String, dynamic> toJson() => {'loggedFor': id, 'glasses': glasses, 'sync': sync.name};

  Map<String, dynamic> toRequest() => {'loggedFor': id, 'glasses': glasses};

  static String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime parseDate(String s) {
    final parts = s.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WaterDay && id == other.id && glasses == other.glasses && sync == other.sync;

  @override
  int get hashCode => Object.hash(id, glasses, sync);
}
