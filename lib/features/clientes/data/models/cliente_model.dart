import '../../domain/entities/cliente.dart';

/// Modelo de datos para Cliente que extiende la entidad del dominio
/// Maneja la serialización/deserialización JSON con el API
class ClienteModel extends Cliente {
  const ClienteModel({
    super.id,
    required super.nombre,
    required super.email,
    required super.telefono,
    super.fechaRegistro,
  });
  
  /// Crea un ClienteModel desde JSON (respuesta del API)
  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : null,
    );
  }
  
  /// Convierte el ClienteModel a JSON para enviar al API
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
    
    // Solo incluye ID si existe (para updates)
    if (id != null) {
      json['id'] = id;
    }
    
    // Solo incluye fechaRegistro si existe
    if (fechaRegistro != null) {
      json['fechaRegistro'] = fechaRegistro!.toIso8601String();
    }
    
    return json;
  }
  
  /// Crea un ClienteModel desde una entidad del dominio
  factory ClienteModel.fromEntity(Cliente cliente) {
    return ClienteModel(
      id: cliente.id,
      nombre: cliente.nombre,
      email: cliente.email,
      telefono: cliente.telefono,
      fechaRegistro: cliente.fechaRegistro,
    );
  }
  
  /// Convierte a entidad del dominio
  Cliente toEntity() {
    return Cliente(
      id: id,
      nombre: nombre,
      email: email,
      telefono: telefono,
      fechaRegistro: fechaRegistro,
    );
  }
  
  /// Crea una copia con nuevos valores
  @override
  ClienteModel copyWith({
    int? id,
    String? nombre,
    String? email,
    String? telefono,
    DateTime? fechaRegistro,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}