import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prestamo.dart';
import '../repositories/prestamos_repository.dart';

class GetPrestamosByClienteUseCase implements UseCase<List<Prestamo>, GetPrestamosByClienteParams> {
  final PrestamosRepository repository;

  const GetPrestamosByClienteUseCase(this.repository);

  @override
  Future<Either<Failure, List<Prestamo>>> call(GetPrestamosByClienteParams params) async {
    return await repository.getPrestamosByCliente(params.clienteId);
  }
}

class GetPrestamosByClienteParams extends Equatable {
  final int clienteId;

  const GetPrestamosByClienteParams({required this.clienteId});

  @override
  List<Object> get props => [clienteId];
}