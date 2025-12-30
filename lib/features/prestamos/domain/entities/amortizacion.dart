import 'package:equatable/equatable.dart';

class Amortizacion extends Equatable {
  final int numeroPago;
  final DateTime fechaPago;
  final double montoCapital;
  final double montoInteres;
  final double montoTotal;
  final double saldoPendiente;
  final bool pagado;

  const Amortizacion({
    required this.numeroPago,
    required this.fechaPago,
    required this.montoCapital,
    required this.montoInteres,
    required this.montoTotal,
    required this.saldoPendiente,
    required this.pagado,
  });

  @override
  List<Object> get props => [
    numeroPago,
    fechaPago,
    montoCapital,
    montoInteres,
    montoTotal,
    saldoPendiente,
    pagado,
  ];
}