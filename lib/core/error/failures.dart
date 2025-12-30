import 'package:equatable/equatable.dart';

/// Clase base para todas las fallas en la aplicación
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Falla de servidor (errores 5xx)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Falla de conexión (sin internet, timeout, etc.)
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

/// Falla de autenticación (401, token inválido, etc.)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Falla de validación (400, datos inválidos, etc.)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falla de caché local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}