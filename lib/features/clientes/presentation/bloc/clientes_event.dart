import 'package:equatable/equatable.dart';
import '../../domain/entities/cliente.dart';

/// Eventos base para el BLoC de clientes
abstract class ClientesEvent extends Equatable {
  const ClientesEvent();
  
  @override
  List<Object> get props => [];
}

/// Evento para cargar todos los clientes
class LoadClientes extends ClientesEvent {
  const LoadClientes();
}

/// Evento para crear un nuevo cliente
class CreateCliente extends ClientesEvent {
  final Cliente cliente;
  
  const CreateCliente({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}

/// Evento para actualizar un cliente existente
class UpdateCliente extends ClientesEvent {
  final Cliente cliente;
  
  const UpdateCliente({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}

/// Evento para eliminar un cliente
class DeleteCliente extends ClientesEvent {
  final int clienteId;
  
  const DeleteCliente({required this.clienteId});
  
  @override
  List<Object> get props => [clienteId];
}

/// Evento para refrescar la lista de clientes
class RefreshClientes extends ClientesEvent {
  const RefreshClientes();
}