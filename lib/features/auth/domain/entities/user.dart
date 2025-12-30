import 'package:equatable/equatable.dart';

/// Entidad que representa un usuario autenticado
/// Esta clase pertenece a la capa de dominio y no debe depender de implementaciones externas
class User extends Equatable {
  final String email;
  final String token;
  final DateTime? expiresAt;
  
  const User({
    required this.email,
    required this.token,
    this.expiresAt,
  });
  
  /// Verifica si el token ha expirado
  bool get isTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  /// Verifica si el usuario está autenticado y el token es válido
  bool get isAuthenticated => token.isNotEmpty && !isTokenExpired;
  
  @override
  List<Object?> get props => [email, token, expiresAt];
}