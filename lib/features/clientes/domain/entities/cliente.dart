import 'package:equatable/equatable.dart';

/// Entidad que representa un cliente
/// Esta clase pertenece a la capa de dominio y define la estructura pura del cliente
class Cliente extends Equatable {
  final int? id;
  final String nombre;
  final String email;
  final String telefono;
  final DateTime? fechaRegistro;
  
  const Cliente({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.fechaRegistro,
  });
  
  /// Verifica si el cliente tiene un ID (está guardado en el servidor)
  bool get isNew => id == null;
  
  /// Crea una copia del cliente con nuevos valores
  Cliente copyWith({
    int? id,
    String? nombre,
    String? email,
    String? telefono,
    DateTime? fechaRegistro,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
  
  @override
  List<Object?> get props => [id, nombre, email, telefono, fechaRegistro];
}