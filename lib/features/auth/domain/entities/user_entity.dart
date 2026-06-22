import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String role;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;
  final Map<String, dynamic>? preferences;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.role,
    required this.isEmailVerified,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.fcmToken,
    this.preferences,
  });

  bool get isAdmin => [
    'super_admin', 'admin', 'product_manager', 'support_agent'
  ].contains(role);

  bool get isSuperAdmin => role == 'super_admin';
  bool get canManageProducts => ['super_admin', 'admin', 'product_manager'].contains(role);
  bool get canManageOrders => ['super_admin', 'admin', 'support_agent'].contains(role);

  UserEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? role,
    bool? isEmailVerified,
    bool? isActive,
    String? fcmToken,
    Map<String, dynamic>? preferences,
  }) => UserEntity(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    role: role ?? this.role,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    fcmToken: fcmToken ?? this.fcmToken,
    preferences: preferences ?? this.preferences,
  );

  @override
  List<Object?> get props => [uid, email, displayName, role, isEmailVerified, isActive];
}
