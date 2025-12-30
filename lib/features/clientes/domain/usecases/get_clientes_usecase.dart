import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cliente.dart';
import '../repositories/clientes_repository.dart';

/// Caso de uso para obtener todos los clientes
/// Encapsula la lógica de negocio para consultar clientes
class GetClientesUseCase implements UseCase<List<Cliente>, NoParams> {
  final ClientesRepository repository;
  
  const GetClientesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<Cliente>>> call(NoParams params) async {
    return await repository.getClientes();
  }
}