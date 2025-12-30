import 'package:equatable/equatable.dart';
import '../../domain/entities/cliente.dart';

abstract class AgregarClienteEvent extends Equatable {
  const AgregarClienteEvent();
  
  @override
  List<Object> get props => [];
}

class CreateClienteEvent extends AgregarClienteEvent {
  final Cliente cliente;
  
  const CreateClienteEvent({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}

class ResetAgregarClienteEvent extends AgregarClienteEvent {
  const ResetAgregarClienteEvent();
}