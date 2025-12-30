import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cliente.dart';

/// Contrato del repositorio de clientes
/// Define las operaciones CRUD que debe implementar cualquier repositorio de clientes
abstract class ClientesRepository {
  /// Obtiene todos los clientes desde el servidor
  /// Retorna Either<Failure, List<Cliente>> donde:
  /// - Left: error al obtener clientes
  /// - Right: lista de clientes
  Future<Either<Failure, List<Cliente>>> getClientes();
  
  /// Crea un nuevo cliente en el servidor
  /// Retorna Either<Failure, Cliente> donde:
  /// - Left: error al crear cliente
  /// - Right: cliente creado con ID asignado
  Future<Either<Failure, Cliente>> createCliente(Cliente cliente);
  
  /// Actualiza un cliente existente
  Future<Either<Failure, Cliente>> updateCliente(Cliente cliente);
  
  /// Elimina un cliente por su ID
  Future<Either<Failure, void>> deleteCliente(int clienteId);
  
  /// Obtiene un cliente específico por su ID
  Future<Either<Failure, Cliente>> getClienteById(int clienteId);
}