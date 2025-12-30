import '../../domain/entities/amortizacion.dart';

class AmortizacionModel extends Amortizacion {
  const AmortizacionModel({
    required super.numeroPago,
    required super.fechaPago,
    required super.montoCapital,
    required super.montoInteres,
    required super.montoTotal,
    required super.saldoPendiente,
    required super.pagado,
  });

  factory AmortizacionModel.fromJson(Map<String, dynamic> json) {
    return AmortizacionModel(
      numeroPago: json['numeroPago'] ?? 0,
      fechaPago: DateTime.parse(json['fechaPago']),
      montoCapital: (json['montoCapital'] ?? 0).toDouble(),
      montoInteres: (json['montoInteres'] ?? 0).toDouble(),
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      saldoPendiente: (json['saldoPendiente'] ?? 0).toDouble(),
      pagado: json['pagado'] ?? false,
    );
  }

  Amortizacion toEntity() {
    return Amortizacion(
      numeroPago: numeroPago,
      fechaPago: fechaPago,
      montoCapital: montoCapital,
      montoInteres: montoInteres,
      montoTotal: montoTotal,
      saldoPendiente: saldoPendiente,
      pagado: pagado,
    );
  }
}