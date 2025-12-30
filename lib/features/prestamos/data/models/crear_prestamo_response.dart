import '../models/prestamo_model.dart';
import '../models/amortizacion_model.dart';

class CrearPrestamoResponse {
  final PrestamoModel prestamo;
  final List<AmortizacionModel> amortizaciones;

  const CrearPrestamoResponse({
    required this.prestamo,
    required this.amortizaciones,
  });

  factory CrearPrestamoResponse.fromJson(Map<String, dynamic> json) {
    return CrearPrestamoResponse(
      prestamo: PrestamoModel.fromJson(json['prestamo']),
      amortizaciones: (json['amortizaciones'] as List)
          .map((amort) => AmortizacionModel.fromJson(amort))
          .toList(),
    );
  }
}