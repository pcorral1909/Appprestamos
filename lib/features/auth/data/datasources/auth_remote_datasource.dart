import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Contrato para el datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  /// Realiza login con email y password
  Future<UserModel> login({required String email, required String password});
}

/// Implementación del datasource remoto de autenticación
/// Se comunica directamente con el API de Azure
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  const AuthRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<UserModel> login({
    required String email, 
    required String password,
  }) async {
    try {
      // Prepara el body de la petición
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      // Realiza la petición POST al endpoint de login
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        data: requestBody,
      );
      
      // Verifica que la respuesta sea exitosa
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Valida que la respuesta contenga el token
        if (responseData is Map<String, dynamic> && 
            responseData.containsKey('token')) {
          
          // Agrega el email a la respuesta para el modelo
          responseData['email'] = email;
          
          return UserModel.fromJson(responseData);
        } else {
          throw const ServerException('Respuesta inválida del servidor');
        }
      } else {
        throw ServerException('Error de autenticación: ${response.statusCode}');
      }
    } catch (e) {
      // Re-lanza excepciones personalizadas
      if (e is AuthException || 
          e is ServerException || 
          e is ConnectionException ||
          e is ValidationException) {
        rethrow;
      }
      
      // Convierte otros errores en ServerException
      throw ServerException('Error inesperado durante el login: $e');
    }
  }
}