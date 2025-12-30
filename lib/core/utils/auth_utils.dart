import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection_container.dart';
import '../network/api_client.dart';

class AuthUtils {
  /// Limpia completamente la sesión del usuario
  static Future<void> clearSession() async {
    try {
      // Limpia SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Limpia el token del ApiClient
      sl<ApiClient>().clearAuthToken();
      
      print('[AUTH_UTILS] Sesión limpiada completamente');
    } catch (e) {
      print('[AUTH_UTILS] Error al limpiar sesión: $e');
    }
  }
}