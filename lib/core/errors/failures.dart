import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message}) : super(statusCode: 0);
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message}) : super(statusCode: -1);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message}) : super(statusCode: 400);
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message}) : super(statusCode: 403);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message}) : super(statusCode: 404);
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message});
}
