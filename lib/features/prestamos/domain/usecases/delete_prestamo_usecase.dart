import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/prestamos_repository.dart';

class DeletePrestamoUseCase implements UseCase<void, DeletePrestamoParams> {
  final PrestamosRepository repository;

  DeletePrestamoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePrestamoParams params) async {
    return await repository.deletePrestamo(params.prestamoId);
  }
}

class DeletePrestamoParams {
  final int prestamoId;

  DeletePrestamoParams({required this.prestamoId});
}