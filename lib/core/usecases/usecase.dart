import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Clase base para todos los casos de uso
/// T es el tipo de retorno, Params son los parámetros de entrada
abstract class UseCase<T, Params> {
  /// Ejecuta el caso de uso
  /// Retorna Either<Failure, T> donde:
  /// - Left: contiene el error (Failure)
  /// - Right: contiene el resultado exitoso (T)
  Future<Either<Failure, T>> call(Params params);
}

/// Clase para casos de uso sin parámetros
class NoParams {
  const NoParams();
}