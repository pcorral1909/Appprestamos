import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/prestamos_repository.dart';

class AbonoCapitalUseCase implements UseCase<void, AbonoCapitalParams> {
  final PrestamosRepository repository;

  AbonoCapitalUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AbonoCapitalParams params) async {
    return await repository.abonoCapital(
      params.prestamoId,
      params.monto,
    );
  }
}

class AbonoCapitalParams {
  final int prestamoId;
  final double monto;

  AbonoCapitalParams({
    required this.prestamoId,
    required this.monto,
  });
}