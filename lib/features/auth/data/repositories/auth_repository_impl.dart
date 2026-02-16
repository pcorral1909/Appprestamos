import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
/// Coordina entre datasources locales y remotos, maneja errores y conectividad
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    // TEMPORAL: Omitir verificación de red para testing con WiFi sin SIM
    /*
    final hasConnection = await networkInfo.isConnected;
    print('[AUTH_REPO] Conexión detectada: $hasConnection');
    
    if (!hasConnection) {
      return const Left(ConnectionFailure('Sin conexión a internet'));
    }
    */
    
    try {
      // Intenta hacer login con el API remoto
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      
      // Guarda el usuario en caché local
      await localDataSource.cacheUser(userModel);
      
      // Retorna la entidad del dominio
      return Right(userModel.toEntity());
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Limpia el caché local
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al cerrar sesión: $e'));
    }
  }
  
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Obtiene el usuario desde el caché local
      final userModel = await localDataSource.getCachedUser();
      
      if (userModel == null) {
        return const Right(null);
      }
      
      // Verifica si el token ha expirado
      final user = userModel.toEntity();
      if (user.isTokenExpired) {
        // Si el token expiró, limpia el caché
        await localDataSource.clearCachedUser();
        return const Right(null);
      }
      
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener usuario actual: $e'));
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    try {
      final result = await getCurrentUser();
      return result.fold(
        (failure) => false,
        (user) => user?.isAuthenticated ?? false,
      );
    } catch (e) {
      return false;
    }
  }
}