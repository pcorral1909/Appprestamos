import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

// Core
import 'core/di/injection_container.dart';
import 'core/services/session_timeout_service.dart';
import 'core/services/token_expiration_service.dart';
import 'core/utils/auth_utils.dart';
import 'core/network/api_client.dart';

// Features
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/clientes/presentation/pages/clientes_page.dart';

// Screens existentes
import 'database/app_database.dart';
import 'screens/dashboard/inicio_page.dart';

void main() async {
  // Asegura que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa las dependencias
  await initializeDependencies();
  
  runApp(const PrestamosApp());
}

class PrestamosApp extends StatefulWidget {
  const PrestamosApp({super.key});

  @override
  State<PrestamosApp> createState() => _PrestamosAppState();
}

class _PrestamosAppState extends State<PrestamosApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Cuando la app se cierra o se minimiza por mucho tiempo
    if (state == AppLifecycleState.detached || 
        state == AppLifecycleState.paused) {
      // Opcional: podrías limpiar la sesión aquí si lo deseas
      // sl<AuthBloc>().add(const LogoutRequested());
    }
    
    // Cuando la app vuelve a primer plano, verifica la autenticación
    if (state == AppLifecycleState.resumed) {
      try {
        sl<AuthBloc>().add(const AuthStatusChecked());
      } catch (e) {
        // Ignora errores si el bloc no está disponible
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Préstamos Corral",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 2, 137, 248),
      ),
      // Usa BlocProvider para el AuthBloc global a nivel de app
      home: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que maneja la navegación basada en el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  void _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      TokenExpirationService().setContext(context);
      // Siempre verifica el estado de autenticación al iniciar
      context.read<AuthBloc>().add(const AuthStatusChecked());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('[AUTH_WRAPPER] Cambio de estado: $state');
        // El listener puede manejar efectos secundarios si es necesario
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('[AUTH] Estado actual: $state');
          
          // Muestra dashboard si está autenticado
          if (state is AuthAuthenticated) {
            print('[AUTH] Mostrando DashboardPage');
            return const DashboardPage();
          }
          
          // Muestra splash screen solo brevemente
          if (state is AuthInitial || state is AuthLoading) {
            return const SplashScreen();
          }
          
          // Muestra login por defecto
          return const LoginPage();
        },
      ),
    );
  }
}

/// Pantalla de splash mientras se verifica la autenticación
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Icon(
              Icons.account_balance,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            
            // Título
            const Text(
              'Préstamos Corral',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            
            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Iniciando aplicación...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard principal que integra las funcionalidades existentes y nuevas
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late final AppDatabase db;
  final SessionTimeoutService _sessionTimeout = SessionTimeoutService();
  final TokenExpirationService _tokenService = TokenExpirationService();
  Key _inicioPageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    // Inicia el timer de sesión
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionTimeout.startTimer(context);
      // Configura el contexto para el servicio de expiración de tokens
      _tokenService.setContext(context);
    });
  }

  @override
  void dispose() {
    _sessionTimeout.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Inicio/Dashboard (nueva página de bienvenida)
          InicioPage(
            key: _inicioPageKey,
            db: db,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          
          // Clientes
          const ClientesPage(),
          
          // Configuración
          const ConfiguracionPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Si selecciona la pestaña de inicio, crear nueva instancia
          if (index == 0) {
            _inicioPageKey = UniqueKey();
          }
          _sessionTimeout.resetTimer(context);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}

/// Página de configuración con opción de logout
class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del usuario
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuario Actual',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return Text(
                          state.user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        );
                      }
                      return const Text('No autenticado');
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Opciones de configuración
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Acerca de'),
                  subtitle: const Text('Información de la aplicación'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.clear_all, color: Colors.orange),
                  title: const Text(
                    'Limpiar Sesión (Debug)',
                    style: TextStyle(color: Colors.orange),
                  ),
                  subtitle: const Text('Limpia la sesión guardada'),
                  onTap: () async {
                    await AuthUtils.clearSession();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sesión limpiada. Reinicia la app.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.blue),
                  title: const Text(
                    'Actualizar Credenciales',
                    style: TextStyle(color: Colors.blue),
                  ),
                  subtitle: const Text('Renovar token de autenticación'),
                  onTap: () {
                    _refreshCredentials(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Préstamos Corral',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.account_balance,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        const Text(
          'Aplicación para la gestión de préstamos y clientes.\n\n'
          'Desarrollado con Flutter y arquitectura limpia.',
        ),
      ],
    );
  }

  void _refreshCredentials(BuildContext context) async {
    try {
      final email = 'peduardo.corral@gmail.com';
      final password = 'Emy\$150421';
      
      final loginUseCase = sl<LoginUseCase>();
      final result = await loginUseCase(LoginParams(
        email: email,
        password: password,
      ));
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (user) {
          sl<ApiClient>().setAuthToken(user.token);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credenciales actualizadas exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performLogout() async {
    try {
      await AuthUtils.clearSession();
      runApp(const PrestamosApp());
    } catch (e) {
      print('Error en logout: $e');
    }
  }
}
