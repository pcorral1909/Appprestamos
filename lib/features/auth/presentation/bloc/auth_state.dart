import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Estados base para el BLoC de autenticación
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando autenticación
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga durante operaciones de auth
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado cuando el usuario está autenticado
class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// Estado cuando el usuario no está autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de error en operaciones de auth
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object> get props => [message];
}