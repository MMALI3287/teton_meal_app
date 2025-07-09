class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? department;
  final String role;
  final String? fcmToken;
  final bool? notificationsEnabled;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.department,
    required this.role,
    this.fcmToken,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      department: map['department'],
      role: map['role'] ?? 'Diner',
      fcmToken: map['fcm_token'],
      notificationsEnabled: map['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'department': department,
      'role': role,
      'fcm_token': fcmToken,
      'notifications_enabled': notificationsEnabled,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? department,
    String? role,
    String? fcmToken,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      department: department ?? this.department,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
