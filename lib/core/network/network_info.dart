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
      // Intenta hacer ping a Google DNS
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}