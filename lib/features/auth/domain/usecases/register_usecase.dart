import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      repository.registerWithEmail(
        email: params.email,
        password: params.password,
        displayName: params.displayName,
      );
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  const RegisterParams({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, displayName];
}
