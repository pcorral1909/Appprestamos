import '../../domain/entities/prestamo.dart';
import 'amortizacion_model.dart';

class PrestamoModel extends Prestamo {
  const PrestamoModel({
    required super.id,
    required super.clienteId,
    required super.monto,
    required super.pagoQuincenal,
    required super.fechaInicio,
    required super.fechaPrimerPago,
    required super.fechaFin,
    required super.tipoPrestamo,
    required super.interesMensual,
    required super.meses,
    required super.amortizaciones,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    final amortizacionesList = json['amortizaciones'] as List? ?? [];
    final amortizaciones = amortizacionesList
        .map((a) => AmortizacionModel.fromJson(a).toEntity())
        .toList();

    return PrestamoModel(
      id: json['id'] ?? 0,
      clienteId: json['clienteId'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
      pagoQuincenal: (json['pagoQuincenal'] ?? 0).toDouble(),
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaPrimerPago: DateTime.parse(json['fechaPrimerPago']),
      fechaFin: DateTime.parse(json['fechaFin']),
      tipoPrestamo: json['tipoPrestamo'] ?? 1,
      interesMensual: (json['interesMensual'] ?? 0).toDouble(),
      meses: json['meses'] ?? 0,
      amortizaciones: amortizaciones,
    );
  }

  Prestamo toEntity() {
    return Prestamo(
      id: id,
      clienteId: clienteId,
      monto: monto,
      pagoQuincenal: pagoQuincenal,
      fechaInicio: fechaInicio,
      fechaPrimerPago: fechaPrimerPago,
      fechaFin: fechaFin,
      tipoPrestamo: tipoPrestamo,
      interesMensual: interesMensual,
      meses: meses,
      amortizaciones: amortizaciones,
    );
  }
}