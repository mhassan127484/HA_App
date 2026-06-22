import 'package:dartz/dartz.dart';
import 'package:ha_ecommerce/core/errors/app_failure.dart';
import 'package:ha_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:ha_ecommerce/features/auth/domain/repositories/i_auth_repository.dart';

class SignInUseCase {
  final IAuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
}

class RegisterUseCase {
  final IAuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    if (displayName.trim().isEmpty) {
      return Future.value(
        const Left(AuthFailure(message: 'Display name cannot be empty.')),
      );
    }
    if (password.length < 8) {
      return Future.value(
        Left(AuthFailure.weakPassword()),
      );
    }
    return _repository.registerWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName.trim(),
    );
  }
}

class ForgotPasswordUseCase {
  final IAuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call({required String email}) =>
      _repository.sendPasswordResetEmail(email: email.trim().toLowerCase());
}

class SignOutUseCase {
  final IAuthRepository _repository;
  const SignOutUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call() => _repository.signOut();
}

class SendEmailVerificationUseCase {
  final IAuthRepository _repository;
  const SendEmailVerificationUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call() =>
      _repository.sendEmailVerification();
}

class UpdateProfileUseCase {
  final IAuthRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) =>
      _repository.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
      );
}
