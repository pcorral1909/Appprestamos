import 'package:equatable/equatable.dart';
import 'amortizacion.dart';

class Prestamo extends Equatable {
  final int id;
  final int clienteId;
  final double monto;
  final double pagoQuincenal;
  final DateTime fechaInicio;
  final DateTime fechaPrimerPago;
  final DateTime fechaFin;
  final int tipoPrestamo;
  final double interesMensual;
  final int meses;
  final List<Amortizacion> amortizaciones;

  const Prestamo({
    required this.id,
    required this.clienteId,
    required this.monto,
    required this.pagoQuincenal,
    required this.fechaInicio,
    required this.fechaPrimerPago,
    required this.fechaFin,
    required this.tipoPrestamo,
    required this.interesMensual,
    required this.meses,
    required this.amortizaciones,
  });

  bool get permiteAbonoCapital => tipoPrestamo == 2 || tipoPrestamo == 3 || tipoPrestamo == 4;

  @override
  List<Object> get props => [
    id,
    clienteId,
    monto,
    pagoQuincenal,
    fechaInicio,
    fechaPrimerPago,
    fechaFin,
    tipoPrestamo,
    interesMensual,
    meses,
    amortizaciones,
  ];
}