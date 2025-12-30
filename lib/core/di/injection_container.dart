import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../network/api_client.dart';
import '../network/network_info.dart';

// Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

  // Clientes
import '../../features/clientes/data/datasources/clientes_remote_datasource.dart';
import '../../features/clientes/data/repositories/clientes_repository_impl.dart';
import '../../features/clientes/domain/repositories/clientes_repository.dart';
import '../../features/clientes/domain/usecases/get_clientes_usecase.dart';
import '../../features/clientes/domain/usecases/create_cliente_usecase.dart';
import '../../features/clientes/domain/usecases/delete_cliente_usecase.dart';
import '../../features/clientes/presentation/bloc/clientes_bloc.dart';
import '../../features/clientes/presentation/bloc/agregar_cliente_bloc.dart';

// Préstamos
import '../../features/prestamos/data/datasources/prestamos_remote_datasource.dart';
import '../../features/prestamos/data/repositories/prestamos_repository_impl.dart';
import '../../features/prestamos/domain/repositories/prestamos_repository.dart';
import '../../features/prestamos/domain/usecases/get_prestamos_by_cliente_usecase.dart';
import '../../features/prestamos/domain/usecases/pagar_amortizacion_usecase.dart';
import '../../features/prestamos/domain/usecases/abono_capital_usecase.dart';
import '../../features/prestamos/domain/usecases/delete_prestamo_usecase.dart';

/// Instancia global del service locator
final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
/// Debe llamarse antes de runApp()
Future<void> initializeDependencies() async {
  // ============================================================================
  // DEPENDENCIAS EXTERNAS (Third Party)
  // ============================================================================
  
  // SharedPreferences - Singleton
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // ============================================================================
  // CORE (Servicios centrales)
  // ============================================================================
  
  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // API Client - Singleton
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // ============================================================================
  // FEATURES - AUTH (Autenticación)
  // ============================================================================
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  
  // BLoC - Factory (nueva instancia cada vez)
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );
  
  // ============================================================================
  // FEATURES - CLIENTES
  // ============================================================================
  
  // Data sources
  sl.registerLazySingleton<ClientesRemoteDataSource>(
    () => ClientesRemoteDataSourceImpl(apiClient: sl()),
  );
  
  // Repository
  sl.registerLazySingleton<ClientesRepository>(
    () => ClientesRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetClientesUseCase(sl()));
  sl.registerLazySingleton(() => CreateClienteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteClienteUseCase(sl()));
  
  // BLoC - Factory (nueva instancia cada vez)
  sl.registerFactory(
    () => ClientesBloc(
      getClientesUseCase: sl(),
      createClienteUseCase: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AgregarClienteBloc(
      createClienteUseCase: sl(),
    ),
  );
  
  // ============================================================================
  // FEATURES - PRÉSTAMOS
  // ============================================================================
  
  // Data sources
  sl.registerLazySingleton<PrestamosRemoteDataSource>(
    () => PrestamosRemoteDataSourceImpl(apiClient: sl()),
  );
  
  // Repository
  sl.registerLazySingleton<PrestamosRepository>(
    () => PrestamosRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetPrestamosByClienteUseCase(sl()));
  sl.registerLazySingleton(() => PagarAmortizacionUseCase(sl()));
  sl.registerLazySingleton(() => AbonoCapitalUseCase(sl()));
  sl.registerLazySingleton(() => DeletePrestamoUseCase(sl()));
}

/// Limpia todas las dependencias registradas
/// Útil para testing
Future<void> resetDependencies() async {
  await sl.reset();
}