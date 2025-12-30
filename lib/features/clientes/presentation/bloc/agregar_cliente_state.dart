import 'package:equatable/equatable.dart';
import '../../domain/entities/cliente.dart';

abstract class AgregarClienteState extends Equatable {
  const AgregarClienteState();
  
  @override
  List<Object> get props => [];
}

class AgregarClienteInitial extends AgregarClienteState {
  const AgregarClienteInitial();
}

class AgregarClienteLoading extends AgregarClienteState {
  const AgregarClienteLoading();
}

class AgregarClienteSuccess extends AgregarClienteState {
  final Cliente cliente;
  
  const AgregarClienteSuccess({required this.cliente});
  
  @override
  List<Object> get props => [cliente];
}

class AgregarClienteError extends AgregarClienteState {
  final String message;
  
  const AgregarClienteError({required this.message});
  
  @override
  List<Object> get props => [message];
}