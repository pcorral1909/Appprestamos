import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/cliente_model.dart';

/// Contrato para el datasource remoto de clientes
abstract class ClientesRemoteDataSource {
  /// Obtiene todos los clientes desde el API
  Future<List<ClienteModel>> getClientes();
  
  /// Crea un nuevo cliente en el API
  Future<ClienteModel> createCliente(ClienteModel cliente);
  
  /// Actualiza un cliente existente
  Future<ClienteModel> updateCliente(ClienteModel cliente);
  
  /// Elimina un cliente por ID
  Future<void> deleteCliente(int clienteId);
  
  /// Obtiene un cliente específico por ID
  Future<ClienteModel> getClienteById(int clienteId);
}

/// Implementación del datasource remoto de clientes
/// Se comunica directamente con el API de Azure
class ClientesRemoteDataSourceImpl implements ClientesRemoteDataSource {
  final ApiClient apiClient;
  
  const ClientesRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<ClienteModel>> getClientes() async {
    try {
      print('[CLIENTES] Iniciando petición GET a ${ApiConstants.clientesEndpoint}');
      
      // Realiza petición GET para obtener todos los clientes
      final response = await apiClient.get(ApiConstants.clientesEndpoint);
      
      print('[CLIENTES] Respuesta recibida: ${response.statusCode}');
      print('[CLIENTES] Datos: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Valida que la respuesta sea una lista
        if (responseData is List) {
          final clientes = responseData
              .map((clienteJson) => ClienteModel.fromJson(clienteJson))
              .toList();
          print('[CLIENTES] ${clientes.length} clientes obtenidos');
          return clientes;
        } else {
          print('[CLIENTES] Error: Respuesta no es una lista: ${responseData.runtimeType}');
          throw const ServerException('Formato de respuesta inválido');
        }
      } else {
        print('[CLIENTES] Error HTTP: ${response.statusCode}');
        throw ServerException('Error al obtener clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('[CLIENTES] Excepción: $e');
      if (e is ServerException || 
          e is ConnectionException || 
          e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al obtener clientes: $e');
    }
  }
  
  @override
  Future<ClienteModel> createCliente(ClienteModel cliente) async {
    try {
      // Prepara el body de la petición (sin ID para creación)
      final requestBody = {
        'nombre': cliente.nombre,
        'email': cliente.email,
        'telefono': cliente.telefono,
      };
      
      print('[CLIENTES] Creando cliente: $requestBody');
      
      // Realiza petición POST para crear cliente
      final response = await apiClient.post(
        ApiConstants.clientesEndpoint,
        data: requestBody,
      );
      
      print('[CLIENTES] Respuesta crear: ${response.statusCode}');
      print('[CLIENTES] Datos respuesta: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          final clienteCreado = ClienteModel.fromJson(responseData);
          print('[CLIENTES] Cliente creado exitosamente: ${clienteCreado.id}');
          return clienteCreado;
        } else {
          print('[CLIENTES] Error: Respuesta no es un mapa');
          throw const ServerException('Formato de respuesta inválido');
        }
      } else {
        print('[CLIENTES] Error HTTP al crear: ${response.statusCode}');
        throw ServerException('Error al crear cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('[CLIENTES] Excepción al crear: $e');
      if (e is ServerException || 
          e is ConnectionException || 
          e is AuthException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Error inesperado al crear cliente: $e');
    }
  }
  
  @override
  Future<ClienteModel> updateCliente(ClienteModel cliente) async {
    try {
      if (cliente.id == null) {
        throw const ValidationException('ID del cliente es requerido para actualizar');
      }
      
      // Realiza petición PUT para actualizar cliente
      final response = await apiClient.put(
        '${ApiConstants.clientesEndpoint}/${cliente.id}',
        data: cliente.toJson(),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          return ClienteModel.fromJson(responseData);
        } else {
          throw const ServerException('Formato de respuesta inválido');
        }
      } else {
        throw ServerException('Error al actualizar cliente: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || 
          e is ConnectionException || 
          e is AuthException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Error inesperado al actualizar cliente: $e');
    }
  }
  
  @override
  Future<void> deleteCliente(int clienteId) async {
    try {
      // Realiza petición DELETE para eliminar cliente
      final response = await apiClient.delete(
        '${ApiConstants.clientesEndpoint}/$clienteId',
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Error al eliminar cliente: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || 
          e is ConnectionException || 
          e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al eliminar cliente: $e');
    }
  }
  
  @override
  Future<ClienteModel> getClienteById(int clienteId) async {
    try {
      // Realiza petición GET para obtener cliente específico
      final response = await apiClient.get(
        '${ApiConstants.clientesEndpoint}/$clienteId',
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          return ClienteModel.fromJson(responseData);
        } else {
          throw const ServerException('Formato de respuesta inválido');
        }
      } else {
        throw ServerException('Error al obtener cliente: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || 
          e is ConnectionException || 
          e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al obtener cliente: $e');
    }
  }
}