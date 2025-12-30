import 'package:equatable/equatable.dart';

/// Eventos base para el BLoC de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

/// Evento para iniciar sesión
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}

/// Evento para cerrar sesión
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Evento para verificar el estado de autenticación al iniciar la app
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}