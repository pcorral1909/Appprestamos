import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
/// Encapsula la lógica de negocio para el logout
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  
  const LogoutUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}