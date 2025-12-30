import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

/// Servicio que maneja el timeout de sesión automático
class SessionTimeoutService {
  static const Duration _timeoutDuration = Duration(minutes: 15);
  Timer? _timer;
  
  /// Inicia el timer de sesión
  void startTimer(BuildContext context) {
    _resetTimer(context);
  }
  
  /// Resetea el timer cuando hay actividad del usuario
  void resetTimer(BuildContext context) {
    _resetTimer(context);
  }
  
  /// Cancela el timer
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  void _resetTimer(BuildContext context) {
    _timer?.cancel();
    _timer = Timer(_timeoutDuration, () {
      _handleTimeout(context);
    });
  }
  
  void _handleTimeout(BuildContext context) {
    // Cierra sesión automáticamente
    if (context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
      
      // Muestra mensaje de timeout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión expirada por inactividad'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}