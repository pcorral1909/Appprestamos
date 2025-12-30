import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/di/injection_container.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC para manejar el estado de autenticación
/// Coordina entre la UI y los casos de uso del dominio
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  
  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    
    // Registra los manejadores de eventos
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  /// Maneja la verificación del estado de autenticación
  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    print('[AUTH] Verificando estado de autenticación...');
    emit(const AuthLoading());
    
    try {
      // Verifica si hay un usuario autenticado
      final result = await authRepository.getCurrentUser();
      
      result.fold(
        (failure) {
          print('[AUTH] Error al obtener usuario: ${failure.message}');
          emit(const AuthUnauthenticated());
        },
        (user) {
          if (user != null && user.isAuthenticated) {
            print('[AUTH] Usuario autenticado encontrado: ${user.email}');
            // Configura el token en el cliente API
            sl<ApiClient>().setAuthToken(user.token);
            emit(AuthAuthenticated(user: user));
          } else {
            print('[AUTH] No hay usuario autenticado');
            emit(const AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      print('[AUTH] Excepción al verificar autenticación: $e');
      emit(const AuthUnauthenticated());
    }
  }
  
  /// Maneja la solicitud de login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('[AUTH] Iniciando login para: ${event.email}');
    emit(const AuthLoading());
    
    try {
      // Ejecuta el caso de uso de login
      final result = await loginUseCase(LoginParams(
        email: event.email,
        password: event.password,
      ));
      
      result.fold(
        (failure) {
          print('[AUTH] Error en login: ${failure.message}');
          emit(AuthError(message: failure.message));
        },
        (user) {
          print('[AUTH] Login exitoso para: ${user.email}');
          // Configura el token en el cliente API
          sl<ApiClient>().setAuthToken(user.token);
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      print('[AUTH] Excepción en login: $e');
      emit(AuthError(message: 'Error inesperado: $e'));
    }
  }
  
  /// Maneja la solicitud de logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      // Ejecuta el caso de uso de logout
      final result = await logoutUseCase(const NoParams());
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (_) {
          // Limpia el token del cliente API
          sl<ApiClient>().clearAuthToken();
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e) {
      emit(AuthError(message: 'Error al cerrar sesión: $e'));
    }
  }
}