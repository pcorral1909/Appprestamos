import 'package:flutter/material.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class TokenExpirationService {
  static final TokenExpirationService _instance = TokenExpirationService._internal();
  factory TokenExpirationService() => _instance;
  TokenExpirationService._internal();

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void handleTokenExpiration() {
    if (_context != null && _context!.mounted) {
      // Emite evento de logout al AuthBloc
      try {
        final authBloc = sl<AuthBloc>();
        authBloc.add(const LogoutRequested());
      } catch (e) {
        // Si no se puede obtener el AuthBloc, navega directamente al login
        Navigator.of(_context!).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}