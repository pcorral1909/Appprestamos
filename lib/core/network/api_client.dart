import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../services/token_expiration_service.dart';

/// Cliente HTTP personalizado usando Dio
/// Maneja interceptores, timeouts y errores de manera centralizada
class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.requestTimeout,
      receiveTimeout: ApiConstants.requestTimeout,
      headers: ApiConstants.defaultHeaders,
    ));
    
    // Interceptor para logging (solo en debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (object) => print('[API] $object'),
    ));
    
    // Interceptor para manejo de errores
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        // Si es error 401, limpia el token y redirige al login
        if (error.response?.statusCode == 401) {
          clearAuthToken();
          TokenExpirationService().handleTokenExpiration();
        }
        _handleDioError(error);
        handler.next(error);
      },
    ));
  }
  
  /// Realiza petición GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Realiza petición POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Realiza petición PUT
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Realiza petición DELETE
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Establece el token de autorización en los headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// Remueve el token de autorización
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  /// Maneja errores de Dio y los convierte en excepciones personalizadas
  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const ConnectionException('Timeout de conexión');
      case DioExceptionType.connectionError:
        throw const ConnectionException('Error de conexión a internet');
      case DioExceptionType.badResponse:
        _handleHttpError(error.response?.statusCode, error.response?.data);
        break;
      default:
        throw const ServerException('Error desconocido');
    }
  }
  
  /// Maneja errores HTTP específicos
  void _handleHttpError(int? statusCode, dynamic responseData) {
    String message = 'Error del servidor';
    
    // Intenta extraer mensaje del response
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? responseData['error'] ?? message;
    }
    
    switch (statusCode) {
      case 400:
        throw ValidationException(message);
      case 401:
        throw const AuthException('Token inválido o expirado');
      case 403:
        throw const AuthException('No tienes permisos para esta acción');
      case 404:
        throw const ServerException('Recurso no encontrado');
      case 500:
      case 502:
      case 503:
        throw ServerException(message);
      default:
        throw ServerException(message);
    }
  }
  
  /// Convierte cualquier error en una excepción personalizada
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      _handleDioError(error);
    }
    
    if (error is ConnectionException ||
        error is ServerException ||
        error is AuthException ||
        error is ValidationException) {
      return error;
    }
    
    return const ServerException('Error desconocido');
  }
}