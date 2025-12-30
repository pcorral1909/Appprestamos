import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Contrato del repositorio de autenticación
/// Define las operaciones que debe implementar cualquier repositorio de auth
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  /// Retorna Either<Failure, User> donde:
  /// - Left: error de autenticación
  /// - Right: usuario autenticado con token
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  
  /// Cierra la sesión del usuario actual
  Future<Either<Failure, void>> logout();
  
  /// Obtiene el usuario actualmente autenticado desde el almacenamiento local
  Future<Either<Failure, User?>> getCurrentUser();
  
  /// Verifica si hay un usuario autenticado
  Future<bool> isAuthenticated();
}