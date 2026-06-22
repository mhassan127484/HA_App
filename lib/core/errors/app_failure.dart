import 'package:equatable/equatable.dart';

// ─── Failure sealed classes ───────────────────────────────────────────────────
abstract class AppFailure extends Equatable {
  final String message;
  final String? code;

  const AppFailure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// Auth failures
class AuthFailure extends AppFailure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.userNotFound() =>
      const AuthFailure(message: 'No account found with this email.', code: 'user-not-found');

  factory AuthFailure.wrongPassword() =>
      const AuthFailure(message: 'Incorrect password. Please try again.', code: 'wrong-password');

  factory AuthFailure.emailAlreadyInUse() =>
      const AuthFailure(message: 'An account already exists with this email.', code: 'email-already-in-use');

  factory AuthFailure.weakPassword() =>
      const AuthFailure(message: 'Password must be at least 8 characters.', code: 'weak-password');

  factory AuthFailure.invalidEmail() =>
      const AuthFailure(message: 'Please enter a valid email address.', code: 'invalid-email');

  factory AuthFailure.networkError() =>
      const AuthFailure(message: 'Network error. Please check your connection.', code: 'network-request-failed');

  factory AuthFailure.tooManyRequests() =>
      const AuthFailure(message: 'Too many attempts. Please try again later.', code: 'too-many-requests');

  factory AuthFailure.unauthorized() =>
      const AuthFailure(message: 'You are not authorized to perform this action.', code: 'unauthorized');

  factory AuthFailure.emailNotVerified() =>
      const AuthFailure(message: 'Please verify your email before signing in.', code: 'email-not-verified');

  factory AuthFailure.unknown(String message) =>
      AuthFailure(message: message, code: 'unknown');
}

// Firestore / data failures
class DatabaseFailure extends AppFailure {
  const DatabaseFailure({required super.message, super.code});

  factory DatabaseFailure.notFound(String entity) =>
      DatabaseFailure(message: '$entity not found.', code: 'not-found');

  factory DatabaseFailure.permissionDenied() =>
      const DatabaseFailure(message: 'Permission denied.', code: 'permission-denied');

  factory DatabaseFailure.networkError() =>
      const DatabaseFailure(message: 'Network error. Please check your connection.', code: 'unavailable');

  factory DatabaseFailure.unknown(String message) =>
      DatabaseFailure(message: message, code: 'unknown');
}

// Storage failures
class StorageFailure extends AppFailure {
  const StorageFailure({required super.message, super.code});

  factory StorageFailure.uploadFailed() =>
      const StorageFailure(message: 'File upload failed. Please try again.', code: 'upload-failed');

  factory StorageFailure.fileTooLarge() =>
      const StorageFailure(message: 'File is too large. Maximum 5MB allowed.', code: 'file-too-large');

  factory StorageFailure.unknown(String message) =>
      StorageFailure(message: message, code: 'unknown');
}

// General failures
class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.noConnection() =>
      const NetworkFailure(message: 'No internet connection.', code: 'no-connection');

  factory NetworkFailure.timeout() =>
      const NetworkFailure(message: 'Request timed out. Please try again.', code: 'timeout');
}

class ServerFailure extends AppFailure {
  const ServerFailure({required super.message, super.code});

  factory ServerFailure.internalError() =>
      const ServerFailure(message: 'An unexpected error occurred.', code: 'internal');
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.message, super.code});
}

class AdminFailure extends AppFailure {
  const AdminFailure({required super.message, super.code});

  factory AdminFailure.insufficientPermissions() =>
      const AdminFailure(message: 'Insufficient permissions for this action.', code: 'insufficient-permissions');

  factory AdminFailure.roleNotFound() =>
      const AdminFailure(message: 'Admin role not found.', code: 'role-not-found');
}
