import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/clientes_repository.dart';
import '../datasources/clientes_remote_datasource.dart';
import '../models/cliente_model.dart';

/// Implementación del repositorio de clientes
/// Coordina con el datasource remoto y maneja errores y conectividad
class ClientesRepositoryImpl implements ClientesRepository {
  final ClientesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  const ClientesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Cliente>>> getClientes() async {
    // Verifica conectividad de red
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }
    
    try {
      // Obtiene clientes desde el API remoto
      final clienteModels = await remoteDataSource.getClientes();
      
      // Convierte a entidades del dominio
      final clientes = clienteModels
          .map((model) => model.toEntity())
          .toList();
      
      return Right(clientes);
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener clientes: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Cliente>> createCliente(Cliente cliente) async {
    // Verifica conectividad de red
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }
    
    try {
      // Convierte entidad a modelo
      final clienteModel = ClienteModel.fromEntity(cliente);
      
      // Crea cliente en el API remoto
      final createdModel = await remoteDataSource.createCliente(clienteModel);
      
      // Retorna entidad del dominio
      return Right(createdModel.toEntity());
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al crear cliente: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Cliente>> updateCliente(Cliente cliente) async {
    // Verifica conectividad de red
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }
    
    try {
      // Convierte entidad a modelo
      final clienteModel = ClienteModel.fromEntity(cliente);
      
      // Actualiza cliente en el API remoto
      final updatedModel = await remoteDataSource.updateCliente(clienteModel);
      
      // Retorna entidad del dominio
      return Right(updatedModel.toEntity());
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al actualizar cliente: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteCliente(int clienteId) async {
    // Verifica conectividad de red
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }
    
    try {
      // Elimina cliente del API remoto
      await remoteDataSource.deleteCliente(clienteId);
      return const Right(null);
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al eliminar cliente: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Cliente>> getClienteById(int clienteId) async {
    // Verifica conectividad de red
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }
    
    try {
      // Obtiene cliente específico desde el API remoto
      final clienteModel = await remoteDataSource.getClienteById(clienteId);
      
      // Retorna entidad del dominio
      return Right(clienteModel.toEntity());
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener cliente: $e'));
    }
  }
}