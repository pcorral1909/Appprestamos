import 'dart:io';

/// Servicio para verificar la conectividad de red
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación del servicio de red
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      // Método más simple y confiable para WiFi sin SIM
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      // Si falla DNS, intenta con una IP directa
      try {
        final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 3));
        socket.destroy();
        return true;
      } catch (e) {
        return false;
      }
    }
  }
}