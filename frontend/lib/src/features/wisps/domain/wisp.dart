import 'package:flutter/foundation.dart';

/// A single reflection saved by the user.
@immutable
class Wisp {
  const Wisp({
    required this.id,
    required this.mood,
    required this.reflection,
    this.createdAt,
  });

  factory Wisp.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    return Wisp(
      id: json['id'] as String,
      mood: json['mood'] as String,
      reflection: json['reflection'] as String,
      createdAt: createdAt is String ? DateTime.tryParse(createdAt)?.toLocal() : null,
    );
  }

  final String id;
  final String mood;
  final String reflection;

  /// Null only in the brief window before the server timestamp is committed.
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood,
        'reflection': reflection,
        'createdAt': createdAt?.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wisp &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mood == other.mood &&
          reflection == other.reflection &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, mood, reflection, createdAt);

  @override
  String toString() => 'Wisp(id: $id, mood: $mood, createdAt: $createdAt)';
}
