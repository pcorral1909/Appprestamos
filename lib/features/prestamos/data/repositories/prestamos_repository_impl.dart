import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/tipo_prestamo.dart';
import '../../domain/repositories/prestamos_repository.dart';
import '../datasources/prestamos_remote_datasource.dart';

class PrestamosRepositoryImpl implements PrestamosRepository {
  final PrestamosRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const PrestamosRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Prestamo>>> getPrestamosByCliente(int clienteId) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      final prestamoModels = await remoteDataSource.getPrestamosByCliente(clienteId);
      final prestamos = prestamoModels.map((model) => model.toEntity()).toList();
      return Right(prestamos);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pagarAmortizacion(int prestamoId, int numeroPago, double montoPagado) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.pagarAmortizacion(prestamoId, numeroPago, montoPagado);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> abonoCapital(int prestamoId, double monto) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.abonoCapital(prestamoId, monto);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TipoPrestamo>>> getTiposPrestamo() async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      final tipoModels = await remoteDataSource.getTiposPrestamo();
      final tipos = tipoModels.map((model) => model.toEntity()).toList();
      return Right(tipos);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> crearPrestamoOrdinario(int clienteId, double monto, DateTime fechaPrimerPago) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.crearPrestamoOrdinario(clienteId, monto, fechaPrimerPago);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> crearPrestamoConTasa(int clienteId, double monto, double tasaInteres, DateTime fechaPrimerPago) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.crearPrestamoConTasa(clienteId, monto, tasaInteres, fechaPrimerPago);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> crearPrestamoMSI(int clienteId, double monto, int meses, DateTime fechaPrimerPago) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.crearPrestamoMSI(clienteId, monto, meses, fechaPrimerPago);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> crearPrestamoLibre(int clienteId, double monto) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.crearPrestamoLibre(clienteId, monto);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrestamo(int prestamoId) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }

    try {
      await remoteDataSource.deletePrestamo(prestamoId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}