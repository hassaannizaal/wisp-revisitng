import 'package:flutter/foundation.dart';

/// Who can ever see this person's data. Spec: docs/screens/03-account-mode.md
enum AccountMode {
  independent,
  organization;

  String get value => name;

  static AccountMode? fromValue(String? value) =>
      value == null ? null : AccountMode.values.firstWhere((m) => m.name == value);
}

/// The signed-in user's own settings. One document, cached on the device.
@immutable
class Profile {
  const Profile({
    required this.uid,
    required this.email,
    this.displayName,
    this.accountMode,
    this.waterGoalGlasses = defaultWaterGoal,
    this.organizationName,
    this.pending = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    uid: json['uid'] as String,
    email: json['email'] as String? ?? '',
    displayName: json['displayName'] as String?,
    accountMode: AccountMode.fromValue(json['accountMode'] as String?),
    waterGoalGlasses: json['waterGoalGlasses'] as int? ?? defaultWaterGoal,
    organizationName: json['organizationName'] as String?,
    pending: json['pending'] as bool? ?? false,
  );

  static const defaultWaterGoal = 8;

  final String uid;
  final String email;
  final String? displayName;

  /// Null until the account-mode screen has been completed.
  final AccountMode? accountMode;
  final int waterGoalGlasses;

  /// Set only in organization mode, once membership exists.
  final String? organizationName;

  /// True while a local change has not reached the server.
  final bool pending;

  /// Nobody but the user can see anything unless they explicitly joined an
  /// organization — so an unset mode is treated as private everywhere.
  bool get isOrganization => accountMode == AccountMode.organization;

  String get firstName {
    final name = (displayName ?? '').trim();
    return name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
  }

  Profile copyWith({
    String? displayName,
    AccountMode? accountMode,
    int? waterGoalGlasses,
    String? organizationName,
    bool? pending,
  }) => Profile(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    accountMode: accountMode ?? this.accountMode,
    waterGoalGlasses: waterGoalGlasses ?? this.waterGoalGlasses,
    organizationName: organizationName ?? this.organizationName,
    pending: pending ?? this.pending,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'accountMode': accountMode?.value,
    'waterGoalGlasses': waterGoalGlasses,
    'organizationName': organizationName,
    'pending': pending,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          accountMode == other.accountMode &&
          waterGoalGlasses == other.waterGoalGlasses &&
          organizationName == other.organizationName &&
          pending == other.pending;

  @override
  int get hashCode => Object.hash(uid, email, displayName, accountMode, waterGoalGlasses, organizationName, pending);
}
