import 'package:flutter/foundation.dart';

import '../../../core/storage/local_first_repository.dart';

/// The regional crisis line. Bundled so the sheet can never depend on a
/// network round trip; the server copy (cached at login) overrides it.
@immutable
class CrisisLine {
  const CrisisLine({required this.name, required this.number, required this.hours});

  factory CrisisLine.fromJson(Map<String, dynamic> json) =>
      CrisisLine(name: json['name'] as String, number: json['number'] as String, hours: json['hours'] as String);

  static const bundled = CrisisLine(name: 'Umang helpline', number: '0311 7786264', hours: '24 hours, every day');

  final String name;
  final String number;
  final String hours;

  Map<String, dynamic> toJson() => {'name': name, 'number': number, 'hours': hours};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisLine && name == other.name && number == other.number && hours == other.hours;

  @override
  int get hashCode => Object.hash(name, number, hours);
}

/// What the person did on the crisis sheet. Signal class only.
enum CrisisAction { opened, called, messaged, breathed }

@immutable
class CrisisEvent implements Syncable {
  const CrisisEvent({required this.id, required this.action, required this.at, this.sync = SyncState.synced});

  factory CrisisEvent.fromJson(Map<String, dynamic> json) => CrisisEvent(
    id: json['id'] as String,
    action: CrisisAction.values.byName(json['action'] as String),
    at: DateTime.parse(json['at'] as String).toLocal(),
    sync: SyncState.values.byName(json['sync'] as String? ?? SyncState.synced.name),
  );

  @override
  final String id;
  final CrisisAction action;
  final DateTime at;
  @override
  final SyncState sync;

  CrisisEvent copyWith({SyncState? sync}) => CrisisEvent(id: id, action: action, at: at, sync: sync ?? this.sync);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action.name,
    'at': at.toUtc().toIso8601String(),
    'sync': sync.name,
  };

  Map<String, dynamic> toRequest() => {'id': id, 'action': action.name, 'at': at.toUtc().toIso8601String()};
}
