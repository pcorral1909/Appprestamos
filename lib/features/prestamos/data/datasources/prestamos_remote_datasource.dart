import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/prestamo_model.dart';
import '../models/tipo_prestamo_model.dart';
import '../models/crear_prestamo_response.dart';

abstract class PrestamosRemoteDataSource {
  Future<List<PrestamoModel>> getPrestamosByCliente(int clienteId);
  Future<void> pagarAmortizacion(int prestamoId, int numeroPago, double montoPagado);
  Future<void> abonoCapital(int prestamoId, double monto);
  Future<List<TipoPrestamoModel>> getTiposPrestamo();
  Future<CrearPrestamoResponse> crearPrestamoOrdinario(int clienteId, double monto, DateTime fechaPrimerPago);
  Future<CrearPrestamoResponse> crearPrestamoConTasa(int clienteId, double monto, double tasaInteres, DateTime fechaPrimerPago);
  Future<CrearPrestamoResponse> crearPrestamoMSI(int clienteId, double monto, int meses, DateTime fechaPrimerPago);
  Future<CrearPrestamoResponse> crearPrestamoLibre(int clienteId, double monto);
  Future<void> deletePrestamo(int prestamoId);
}

class PrestamosRemoteDataSourceImpl implements PrestamosRemoteDataSource {
  final ApiClient apiClient;

  const PrestamosRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PrestamoModel>> getPrestamosByCliente(int clienteId) async {
    try {
      final response = await apiClient.get('/PrestamosV2/cliente/$clienteId');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is List) {
          return responseData
              .map((prestamoJson) => PrestamoModel.fromJson(prestamoJson))
              .toList();
        } else {
          throw const ServerException('Formato de respuesta inválido');
        }
      } else {
        throw ServerException('Error al obtener préstamos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al obtener préstamos: $e');
    }
  }

  @override
  Future<void> pagarAmortizacion(int prestamoId, int numeroPago, double montoPagado) async {
    try {
      final requestBody = {
        'prestamoId': prestamoId,
        'numeroPago': numeroPago,
        'montoPagado': montoPagado,
      };

      final response = await apiClient.post(
        '/PrestamosV2/$prestamoId/pagar-amortizacion',
        data: requestBody,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Error al pagar amortización: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al pagar amortización: $e');
    }
  }

  @override
  Future<void> abonoCapital(int prestamoId, double monto) async {
    try {
      final requestBody = {'monto': monto};

      final response = await apiClient.post(
        '/PrestamosV2/$prestamoId/abono',
        data: requestBody,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Error al realizar abono: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al realizar abono: $e');
    }
  }

  @override
  Future<List<TipoPrestamoModel>> getTiposPrestamo() async {
    try {
      final response = await apiClient.get('/PrestamosV2/tipos');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is List) {
          return responseData
              .map((tipoJson) => TipoPrestamoModel.fromJson(tipoJson))
              .toList();
        } else {
          throw const ServerException('Formato de respuesta inválido');
        }
      } else {
        throw ServerException('Error al obtener tipos de préstamo: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al obtener tipos de préstamo: $e');
    }
  }

  @override
  Future<CrearPrestamoResponse> crearPrestamoOrdinario(int clienteId, double monto, DateTime fechaPrimerPago) async {
    try {
      final requestBody = {
        'clienteId': clienteId,
        'monto': monto,
        'fechaPrimerPago': fechaPrimerPago.toIso8601String(),
      };

      final response = await apiClient.post('/PrestamosV2/ordinario', data: requestBody);

      if (response.statusCode == 200) {
        return CrearPrestamoResponse.fromJson(response.data);
      } else {
        throw ServerException('Error al crear préstamo ordinario: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al crear préstamo ordinario: $e');
    }
  }

  @override
  Future<CrearPrestamoResponse> crearPrestamoConTasa(int clienteId, double monto, double tasaInteres, DateTime fechaPrimerPago) async {
    try {
      final requestBody = {
        'clienteId': clienteId,
        'monto': monto,
        'tasaInteres': tasaInteres,
        'fechaPrimerPago': fechaPrimerPago.toIso8601String(),
      };

      final response = await apiClient.post('/PrestamosV2/con-tasa', data: requestBody);

      if (response.statusCode == 200) {
        return CrearPrestamoResponse.fromJson(response.data);
      } else {
        throw ServerException('Error al crear préstamo con tasa: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al crear préstamo con tasa: $e');
    }
  }

  @override
  Future<CrearPrestamoResponse> crearPrestamoMSI(int clienteId, double monto, int meses, DateTime fechaPrimerPago) async {
    try {
      final requestBody = {
        'clienteId': clienteId,
        'monto': monto,
        'meses': meses,
        'fechaPrimerPago': fechaPrimerPago.toIso8601String(),
      };

      final response = await apiClient.post('/PrestamosV2/msi', data: requestBody);

      if (response.statusCode == 200) {
        return CrearPrestamoResponse.fromJson(response.data);
      } else {
        throw ServerException('Error al crear préstamo MSI: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al crear préstamo MSI: $e');
    }
  }

  @override
  Future<CrearPrestamoResponse> crearPrestamoLibre(int clienteId, double monto) async {
    try {
      final requestBody = {
        'clienteId': clienteId,
        'monto': monto,
      };

      final response = await apiClient.post('/PrestamosV2/libre', data: requestBody);

      if (response.statusCode == 200) {
        // Para préstamo libre, la respuesta es directamente el préstamo sin amortizaciones
        final prestamoData = response.data;
        return CrearPrestamoResponse(
          prestamo: PrestamoModel.fromJson(prestamoData),
          amortizaciones: [], // Préstamo libre no tiene amortizaciones
        );
      } else {
        throw ServerException('Error al crear préstamo libre: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al crear préstamo libre: $e');
    }
  }

  @override
  Future<void> deletePrestamo(int prestamoId) async {
    try {
      final response = await apiClient.delete('/PrestamosV2/$prestamoId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Error al eliminar préstamo: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Error inesperado al eliminar préstamo: $e');
    }
  }
}