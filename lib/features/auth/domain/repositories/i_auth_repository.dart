import 'package:dartz/dartz.dart';
import 'package:ha_ecommerce/core/errors/app_failure.dart';
import 'package:ha_ecommerce/features/auth/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  /// Stream of the currently signed-in user (null when signed out)
  Stream<UserEntity?> get authStateChanges;

  /// Current user (null if not signed in)
  UserEntity? get currentUser;

  /// Sign in with email + password
  Future<Either<AuthFailure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<AuthFailure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Send password reset email
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({required String email});

  /// Send email verification
  Future<Either<AuthFailure, Unit>> sendEmailVerification();

  /// Sign out
  Future<Either<AuthFailure, Unit>> signOut();

  /// Delete account
  Future<Either<AuthFailure, Unit>> deleteAccount();

  /// Update profile
  Future<Either<AuthFailure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  });

  /// Update FCM token in Firestore
  Future<Either<DatabaseFailure, Unit>> updateFcmToken(String token);

  /// Reload user (check email verification status)
  Future<Either<AuthFailure, UserEntity>> reloadUser();
}
