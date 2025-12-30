import '../../domain/entities/tipo_prestamo.dart';

class TipoPrestamoModel extends TipoPrestamo {
  const TipoPrestamoModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
  });

  factory TipoPrestamoModel.fromJson(Map<String, dynamic> json) {
    return TipoPrestamoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  TipoPrestamo toEntity() {
    return TipoPrestamo(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
    );
  }
}