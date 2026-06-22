import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDataSource.registerWithEmail(
        email: email, password: password, displayName: displayName,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        displayName: displayName, photoUrl: photoUrl, phoneNumber: phoneNumber,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      await remoteDataSource.updateFcmToken(token);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }
}
