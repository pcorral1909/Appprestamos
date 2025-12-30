import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/clientes_repository.dart';

class DeleteClienteUseCase implements UseCase<void, DeleteClienteParams> {
  final ClientesRepository repository;

  DeleteClienteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteClienteParams params) async {
    return await repository.deleteCliente(params.clienteId);
  }
}

class DeleteClienteParams {
  final int clienteId;

  DeleteClienteParams({required this.clienteId});
}