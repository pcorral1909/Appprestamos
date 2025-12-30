import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cliente.dart';
import '../repositories/clientes_repository.dart';

/// Caso de uso para crear un nuevo cliente
/// Encapsula la lógica de negocio y validaciones para crear clientes
class CreateClienteUseCase implements UseCase<Cliente, CreateClienteParams> {
  final ClientesRepository repository;
  
  const CreateClienteUseCase(this.repository);
  
  @override
  Future<Either<Failure, Cliente>> call(CreateClienteParams params) async {
    // Validaciones de negocio
    final validationResult = _validateClienteData(params.cliente);
    if (validationResult != null) {
      return Left(ValidationFailure(validationResult));
    }
    
    // Delega la creación al repositorio
    return await repository.createCliente(params.cliente);
  }
  
  /// Valida los datos del cliente antes de crear
  String? _validateClienteData(Cliente cliente) {
    if (cliente.nombre.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (cliente.nombre.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (cliente.email.trim().isEmpty) {
      return 'El email es requerido';
    }
    
    if (!_isValidEmail(cliente.email)) {
      return 'El formato del email no es válido';
    }
    
    if (cliente.telefono.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    
    if (!_isValidPhone(cliente.telefono)) {
      return 'El formato del teléfono no es válido';
    }
    
    return null; // Sin errores
  }
  
  /// Valida el formato del email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }
  
  /// Valida el formato del teléfono (solo números, mínimo 10 dígitos)
  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanPhone.length >= 10;
  }
}

/// Parámetros para el caso de uso de crear cliente
class CreateClienteParams extends Equatable {
  final Cliente cliente;
  
  const CreateClienteParams({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}