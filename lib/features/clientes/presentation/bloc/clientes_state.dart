import 'package:equatable/equatable.dart';
import '../../domain/entities/cliente.dart';

/// Estados base para el BLoC de clientes
abstract class ClientesState extends Equatable {
  const ClientesState();
  
  @override
  List<Object> get props => [];
}

/// Estado inicial
class ClientesInitial extends ClientesState {
  const ClientesInitial();
}

/// Estado de carga
class ClientesLoading extends ClientesState {
  const ClientesLoading();
}

/// Estado cuando los clientes se han cargado exitosamente
class ClientesLoaded extends ClientesState {
  final List<Cliente> clientes;
  
  const ClientesLoaded({required this.clientes});
  
  @override
  List<Object> get props => [clientes];
}

/// Estado cuando se ha creado un cliente exitosamente
class ClienteCreated extends ClientesState {
  final Cliente cliente;
  
  const ClienteCreated({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}

/// Estado cuando se ha actualizado un cliente exitosamente
class ClienteUpdated extends ClientesState {
  final Cliente cliente;
  
  const ClienteUpdated({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}

/// Estado cuando se ha eliminado un cliente exitosamente
class ClienteDeleted extends ClientesState {
  final int clienteId;
  
  const ClienteDeleted({required this.clienteId});
  
  @override
  List<Object> get props => [clienteId];
}

/// Estado de error
class ClientesError extends ClientesState {
  final String message;
  
  const ClientesError({required this.message});
  
  @override
  List<Object> get props => [message];
}