/// Excepción base para errores de servidor
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

/// Excepción para errores de conexión
class ConnectionException implements Exception {
  final String message;
  const ConnectionException(this.message);
}

/// Excepción para errores de autenticación
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

/// Excepción para errores de validación
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

/// Excepción para errores de caché
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}