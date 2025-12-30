import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_clientes_usecase.dart';
import '../../domain/usecases/create_cliente_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'clientes_event.dart';
import 'clientes_state.dart';

/// BLoC para manejar el estado de clientes
/// Coordina entre la UI y los casos de uso del dominio
class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  final GetClientesUseCase getClientesUseCase;
  final CreateClienteUseCase createClienteUseCase;
  
  ClientesBloc({
    required this.getClientesUseCase,
    required this.createClienteUseCase,
  }) : super(const ClientesInitial()) {
    
    // Registra los manejadores de eventos
    on<LoadClientes>(_onLoadClientes);
    on<CreateCliente>(_onCreateCliente);
    on<RefreshClientes>(_onRefreshClientes);
  }
  
  /// Maneja la carga de clientes
  Future<void> _onLoadClientes(
    LoadClientes event,
    Emitter<ClientesState> emit,
  ) async {
    print('[CLIENTES_BLOC] Iniciando carga de clientes');
    emit(const ClientesLoading());
    
    try {
      // Ejecuta el caso de uso para obtener clientes
      final result = await getClientesUseCase(const NoParams());
      
      result.fold(
        (failure) {
          print('[CLIENTES_BLOC] Error: ${failure.message}');
          emit(ClientesError(message: failure.message));
        },
        (clientes) {
          print('[CLIENTES_BLOC] Clientes cargados: ${clientes.length}');
          emit(ClientesLoaded(clientes: clientes));
        },
      );
    } catch (e) {
      print('[CLIENTES_BLOC] Excepción: $e');
      emit(ClientesError(message: 'Error inesperado: $e'));
    }
  }
  
  /// Maneja la creación de un nuevo cliente
  Future<void> _onCreateCliente(
    CreateCliente event,
    Emitter<ClientesState> emit,
  ) async {
    print('[CLIENTES_BLOC] Iniciando creación de cliente: ${event.cliente.nombre}');
    emit(const ClientesLoading());
    
    try {
      // Ejecuta el caso de uso para crear cliente
      final result = await createClienteUseCase(
        CreateClienteParams(cliente: event.cliente),
      );
      
      result.fold(
        (failure) {
          print('[CLIENTES_BLOC] Error al crear: ${failure.message}');
          emit(ClientesError(message: failure.message));
        },
        (cliente) {
          print('[CLIENTES_BLOC] Cliente creado: ${cliente.id}');
          emit(ClienteCreated(cliente: cliente));
        },
      );
    } catch (e) {
      print('[CLIENTES_BLOC] Excepción al crear: $e');
      emit(ClientesError(message: 'Error inesperado: $e'));
    }
  }
  
  /// Maneja el refresco de la lista de clientes
  Future<void> _onRefreshClientes(
    RefreshClientes event,
    Emitter<ClientesState> emit,
  ) async {
    // Reutiliza la lógica de LoadClientes
    add(const LoadClientes());
  }
}