import '../database/app_database.dart';

extension PrestamoHelper on Prestamo {
  List<Map<String, dynamic>> generarAmortizacion(int quincenas) {
    final pago = pagoQuincenal;
    List<Map<String, dynamic>> lista = [];
    for (int i = 0; i < quincenas; i++) {
      final fechaPago = fechaInicio.add(Duration(days: i * 15));
      lista.add({'fecha': fechaPago, 'monto': pago, 'pagoNumero': i + 1});
    }
    return lista;
  }
}
