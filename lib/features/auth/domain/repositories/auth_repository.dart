import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  });

  Future<Either<Failure, void>> updateFcmToken(String token);

  Future<Either<Failure, void>> deleteAccount();
}
