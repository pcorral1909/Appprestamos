/// Constantes para la configuración del API
class ApiConstants {
  /// URL base del API de Azure
  static const String baseUrl = 'https://prestamoscorrral-gzbbh8fpcpdgesdw.mexicocentral-01.azurewebsites.net/api';
  
  /// Endpoints específicos
  static const String loginEndpoint = '/Auth/login';
  static const String clientesEndpoint = '/ClientesV2';
  
  /// Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Timeout para las peticiones HTTP
  static const Duration requestTimeout = Duration(seconds: 30);
}