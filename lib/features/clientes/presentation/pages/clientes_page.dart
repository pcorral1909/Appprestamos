import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../utils/delete_utils.dart';
import '../bloc/clientes_bloc.dart';
import '../bloc/clientes_event.dart';
import '../bloc/clientes_state.dart';
import '../widgets/cliente_card.dart';
import 'agregar_cliente_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  late ClientesBloc _clientesBloc;

  @override
  void initState() {
    super.initState();
    _clientesBloc = sl<ClientesBloc>();
    _clientesBloc.add(const LoadClientes());
  }

  @override
  void dispose() {
    _clientesBloc.close();
    super.dispose();
  }

  void _reloadClientes() {
    _clientesBloc.add(const LoadClientes());
  }

  Future<void> _navigateToAgregarCliente() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AgregarClientePage(),
      ),
    );
    
    if (result == true) {
      _reloadClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadClientes,
          ),
        ],
      ),
      body: BlocBuilder<ClientesBloc, ClientesState>(
        bloc: _clientesBloc,
        builder: (context, state) {
          if (state is ClientesLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando clientes...'),
                ],
              ),
            );
          }
          
          if (state is ClientesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reloadClientes,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          if (state is ClientesLoaded) {
            if (state.clientes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay clientes registrados'),
                    SizedBox(height: 8),
                    Text('Toca el botón + para agregar el primer cliente'),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.clientes.length,
              itemBuilder: (context, index) {
                final cliente = state.clientes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClienteCard(
                    cliente: cliente,
                    onDelete: () async {
                      await DeleteUtils.deleteCliente(
                        context,
                        cliente.id!,
                        cliente.nombre,
                      );
                      _reloadClientes();
                    },
                  ),
                );
              },
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAgregarCliente,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}