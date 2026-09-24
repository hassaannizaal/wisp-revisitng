import 'package:flutter/material.dart';

/// Five named states, never a number (design rule 6). Declaration order runs
/// low → bright so the neutral option sits in the middle of any list.
enum Mood {
  low('Low', 'Heavy, flat, hard to move', Icons.cloud_outlined),
  flat('Flat', 'Neither here nor there', Icons.horizontal_rule_rounded),
  okay('Okay', 'Getting through it', Icons.circle_outlined),
  good('Good', 'Steady, a bit of lift', Icons.wb_twilight_outlined),
  bright('Bright', 'Genuinely light today', Icons.wb_sunny_outlined);

  const Mood(this.label, this.hint, this.icon);

  final String label;
  final String hint;
  final IconData icon;

  /// The wire value: the enum name, e.g. `okay`.
  String get value => name;

  static Mood fromValue(String value) => Mood.values.firstWhere((m) => m.name == value);
}

/// Whether the server has this exact version of a log yet.
enum SyncState {
  /// Server has it, and it matches.
  synced,

  /// Written on the device, never sent — needs `POST`.
  pendingCreate,

  /// Exists on the server, but the mood was changed since — needs `PATCH`.
  pendingUpdate,
}

/// One check-in. Created on the device with its own id so it can be written
/// before the network is involved and replayed safely.
@immutable
class MoodLog {
  const MoodLog({required this.id, required this.mood, required this.loggedAt, this.sync = SyncState.synced});

  /// Parses both the server shape and the local shape (which adds `sync`).
  factory MoodLog.fromJson(Map<String, dynamic> json) => MoodLog(
    id: json['id'] as String,
    mood: Mood.fromValue(json['mood'] as String),
    loggedAt: DateTime.parse(json['loggedAt'] as String).toLocal(),
    sync: SyncState.values.byName(json['sync'] as String? ?? SyncState.synced.name),
  );

  final String id;
  final Mood mood;

  /// When the user says it happened (local time).
  final DateTime loggedAt;
  final SyncState sync;

  bool get isSynced => sync == SyncState.synced;

  MoodLog copyWith({Mood? mood, SyncState? sync}) =>
      MoodLog(id: id, mood: mood ?? this.mood, loggedAt: loggedAt, sync: sync ?? this.sync);

  Map<String, dynamic> toJson() => {
    'id': id,
    'mood': mood.value,
    'loggedAt': loggedAt.toUtc().toIso8601String(),
    'sync': sync.name,
  };

  /// The request body for `POST /api/moods`.
  Map<String, dynamic> toRequest() => {'id': id, 'mood': mood.value, 'loggedAt': loggedAt.toUtc().toIso8601String()};

  bool isOn(DateTime day) => loggedAt.year == day.year && loggedAt.month == day.month && loggedAt.day == day.day;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mood == other.mood &&
          loggedAt == other.loggedAt &&
          sync == other.sync;

  @override
  int get hashCode => Object.hash(id, mood, loggedAt, sync);

  @override
  String toString() => 'MoodLog($id, ${mood.value}, $loggedAt, ${sync.name})';
}
