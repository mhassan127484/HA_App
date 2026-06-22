class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
  @override String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
  @override String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
  @override String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
  @override String toString() => 'CacheException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException({required this.message});
  @override String toString() => 'StorageException: $message';
}

class PermissionException implements Exception {
  final String message;
  const PermissionException({required this.message});
  @override String toString() => 'PermissionException: $message';
}
