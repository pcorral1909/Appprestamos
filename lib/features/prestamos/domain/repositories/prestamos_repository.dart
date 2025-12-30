import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prestamo.dart';
import '../entities/tipo_prestamo.dart';

abstract class PrestamosRepository {
  Future<Either<Failure, List<Prestamo>>> getPrestamosByCliente(int clienteId);
  Future<Either<Failure, void>> pagarAmortizacion(int prestamoId, int numeroPago, double montoPagado);
  Future<Either<Failure, void>> abonoCapital(int prestamoId, double monto);
  Future<Either<Failure, List<TipoPrestamo>>> getTiposPrestamo();
  Future<Either<Failure, void>> crearPrestamoOrdinario(int clienteId, double monto, DateTime fechaPrimerPago);
  Future<Either<Failure, void>> crearPrestamoConTasa(int clienteId, double monto, double tasaInteres, DateTime fechaPrimerPago);
  Future<Either<Failure, void>> crearPrestamoMSI(int clienteId, double monto, int meses, DateTime fechaPrimerPago);
  Future<Either<Failure, void>> crearPrestamoLibre(int clienteId, double monto);
  Future<Either<Failure, void>> deletePrestamo(int prestamoId);
}