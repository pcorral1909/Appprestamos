import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/user.dart';

/// Modelo de datos para User que extiende la entidad del dominio
/// Maneja la serialización/deserialización JSON y lógica específica de datos
class UserModel extends User {
  const UserModel({
    required super.email,
    required super.token,
    super.expiresAt,
  });
  
  /// Crea un UserModel desde JSON (respuesta del API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String;
    
    // Extrae información del JWT token
    DateTime? expiresAt;
    String email = '';
    
    try {
      if (!JwtDecoder.isExpired(token)) {
        final decodedToken = JwtDecoder.decode(token);
        
        // Extrae email del token (puede estar en diferentes campos)
        email = decodedToken['email'] ?? 
                decodedToken['sub'] ?? 
                decodedToken['unique_name'] ?? 
                json['email'] ?? '';
        
        // Extrae fecha de expiración
        if (decodedToken['exp'] != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(
            decodedToken['exp'] * 1000,
          );
        }
      }
    } catch (e) {
      // Si hay error decodificando el token, usa datos del JSON
      email = json['email'] ?? '';
    }
    
    return UserModel(
      email: email,
      token: token,
      expiresAt: expiresAt,
    );
  }
  
  /// Convierte el UserModel a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
  
  /// Crea un UserModel desde JSON almacenado localmente
  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }
  
  /// Convierte a entidad del dominio
  User toEntity() {
    return User(
      email: email,
      token: token,
      expiresAt: expiresAt,
    );
  }
}