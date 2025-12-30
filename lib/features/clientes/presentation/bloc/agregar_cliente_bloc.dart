import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_cliente_usecase.dart';
import 'agregar_cliente_event.dart';
import 'agregar_cliente_state.dart';

class AgregarClienteBloc extends Bloc<AgregarClienteEvent, AgregarClienteState> {
  final CreateClienteUseCase createClienteUseCase;
  
  AgregarClienteBloc({
    required this.createClienteUseCase,
  }) : super(const AgregarClienteInitial()) {
    on<CreateClienteEvent>(_onCreateCliente);
    on<ResetAgregarClienteEvent>(_onReset);
  }
  
  Future<void> _onCreateCliente(
    CreateClienteEvent event,
    Emitter<AgregarClienteState> emit,
  ) async {
    emit(const AgregarClienteLoading());
    
    try {
      final result = await createClienteUseCase(
        CreateClienteParams(cliente: event.cliente),
      );
      
      result.fold(
        (failure) => emit(AgregarClienteError(message: failure.message)),
        (cliente) => emit(AgregarClienteSuccess(cliente: cliente)),
      );
    } catch (e) {
      emit(AgregarClienteError(message: 'Error inesperado: $e'));
    }
  }
  
  void _onReset(
    ResetAgregarClienteEvent event,
    Emitter<AgregarClienteState> emit,
  ) {
    emit(const AgregarClienteInitial());
  }
}