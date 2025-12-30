import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Contrato para el datasource local de autenticación
abstract class AuthLocalDataSource {
  /// Guarda el usuario en el almacenamiento local
  Future<void> cacheUser(UserModel user);
  
  /// Obtiene el usuario desde el almacenamiento local
  Future<UserModel?> getCachedUser();
  
  /// Elimina el usuario del almacenamiento local
  Future<void> clearCachedUser();
}

/// Implementación del datasource local de autenticación
/// Usa SharedPreferences para persistir datos del usuario
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  // Clave para almacenar los datos del usuario
  static const String _userKey = 'CACHED_USER';
  
  const AuthLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      // Convierte el usuario a JSON y lo guarda
      final userJson = json.encode(user.toJson());
      final success = await sharedPreferences.setString(_userKey, userJson);
      
      if (!success) {
        throw const CacheException('Error al guardar usuario en caché');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error inesperado al guardar usuario: $e');
    }
  }
  
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      // Obtiene el JSON del usuario desde SharedPreferences
      final userJson = sharedPreferences.getString(_userKey);
      
      if (userJson == null) {
        return null; // No hay usuario guardado
      }
      
      // Decodifica el JSON y crea el UserModel
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromLocalJson(userMap);
      
    } catch (e) {
      throw CacheException('Error al obtener usuario desde caché: $e');
    }
  }
  
  @override
  Future<void> clearCachedUser() async {
    try {
      final success = await sharedPreferences.remove(_userKey);
      
      if (!success) {
        throw const CacheException('Error al limpiar caché de usuario');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error inesperado al limpiar caché: $e');
    }
  }
}