import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.role,
    required super.isEmailVerified,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
    super.fcmToken,
    super.preferences,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      role: data['role'] ?? 'customer',
      isEmailVerified: data['isEmailVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      fcmToken: data['fcmToken'],
      preferences: data['preferences'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    displayName: map['displayName'],
    photoUrl: map['photoUrl'],
    phoneNumber: map['phoneNumber'],
    role: map['role'] ?? 'customer',
    isEmailVerified: map['isEmailVerified'] ?? false,
    isActive: map['isActive'] ?? true,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    fcmToken: map['fcmToken'],
    preferences: map['preferences'],
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'role': role,
    'isEmailVerified': isEmailVerified,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'fcmToken': fcmToken,
    'preferences': preferences,
  };
}
