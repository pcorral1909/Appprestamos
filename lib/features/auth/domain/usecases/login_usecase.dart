import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
/// Encapsula la lógica de negocio para la autenticación
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;
  
  const LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // Validaciones de negocio
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('El email es requerido'));
    }
    
    if (params.password.isEmpty) {
      return const Left(ValidationFailure('La contraseña es requerida'));
    }
    
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure('El formato del email no es válido'));
    }
    
    // Delega la implementación al repositorio
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
  
  /// Valida el formato del email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }
}

/// Parámetros para el caso de uso de login
class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}