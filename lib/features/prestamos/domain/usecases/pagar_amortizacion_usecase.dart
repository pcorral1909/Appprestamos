import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/prestamos_repository.dart';

class PagarAmortizacionUseCase implements UseCase<void, PagarAmortizacionParams> {
  final PrestamosRepository repository;

  PagarAmortizacionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PagarAmortizacionParams params) async {
    return await repository.pagarAmortizacion(
      params.prestamoId,
      params.numeroPago,
      params.monto,
    );
  }
}

class PagarAmortizacionParams {
  final int prestamoId;
  final int numeroPago;
  final double monto;

  PagarAmortizacionParams({
    required this.prestamoId,
    required this.numeroPago,
    required this.monto,
  });
}