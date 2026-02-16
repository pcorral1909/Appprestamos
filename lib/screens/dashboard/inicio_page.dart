import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/clientes/presentation/pages/clientes_page.dart';
import '../../features/clientes/presentation/pages/agregar_cliente_page.dart';
import '../prestamos/proximos_pagos_page.dart';
import '../../database/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/di/injection_container.dart';

class InicioPage extends StatefulWidget {
  final AppDatabase db;
  final Function(int)? onTabChange;
  
  const InicioPage({super.key, required this.db, this.onTabChange});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  Map<String, dynamic>? _resumenData;
  bool _isLoading = true;
  DateTime? _lastLoad;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    // Evitar llamadas muy frecuentes (mínimo 10 segundos entre llamadas)
    final now = DateTime.now();
    if (_lastLoad != null && now.difference(_lastLoad!).inSeconds < 10) {
      return;
    }
    
    setState(() => _isLoading = true);
    _lastLoad = now;
    
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.get('/dashboard/resumen');
      
      if (response.statusCode == 200) {
        setState(() {
          _resumenData = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar resumen');
      }
    } catch (e) {
      print('Error cargando resumen: $e');
      setState(() {
        _resumenData = {
          'totalPrestado': 0.0,
          'saldoPendiente': 0.0,
          'interesesGanados': 0.0,
          'prestamosActivos': 0,
          'totalClientes': 0,
        };
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _cargarResumen,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSaludo(context),
                      const SizedBox(height: 30),
                      _buildResumenRapido(context),
                      const SizedBox(height: 30),
                      _buildAccesosRapidos(context),
                      const SizedBox(height: 30),
                      _buildSeccionGraficas(context),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSaludo(BuildContext context) {
    final hora = DateTime.now().hour;
    String saludo;
    
    if (hora < 12) {
      saludo = "Buenos días";
    } else if (hora < 18) {
      saludo = "Buenas tardes";
    } else {
      saludo = "Buenas noches";
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String nombre = "Usuario";
        if (state is AuthAuthenticated) {
          // Extraer nombre del email o usar email completo
          nombre = state.user.email.split('@').first;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              saludo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              nombre,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bienvenido a tu panel de préstamos",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResumenRapido(BuildContext context) {
    final datos = _resumenData ?? {
      'totalPrestado': 0.0,
      'saldoPendiente': 0.0,
      'interesesGanados': 0.0,
      'prestamosActivos': 0,
      'totalClientes': 0,
    };
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen rápido",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEstadistica(
                    "Total prestado",
                    "\$${(datos['totalPrestado'] ?? 0.0).toStringAsFixed(2)}",
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstadistica(
                    "Saldo pendiente",
                    "\$${(datos['saldoPendiente'] ?? 0.0).toStringAsFixed(2)}",
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEstadistica(
                    "Intereses ganados",
                    "\$${(datos['interesesGanados'] ?? 0.0).toStringAsFixed(2)}",
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstadistica(
                    "Préstamos activos",
                    "${datos['prestamosActivos'] ?? 0}",
                    Icons.assignment,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: _buildEstadistica(
                "Total clientes",
                "${datos['totalClientes'] ?? 0}",
                Icons.people,
                Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadistica(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesosRapidos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Accesos rápidos",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildAccesoRapido(
              "Nuevo Cliente",
              Icons.person_add,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgregarClientePage(),
                  ),
                );
              },
            ),
            _buildAccesoRapido(
              "Nuevo Préstamo",
              Icons.add_card,
              Colors.grey,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecciona un cliente primero desde la sección Clientes'),
                  ),
                );
              },
            ),
            _buildAccesoRapido(
              "Ver Clientes",
              Icons.people,
              Colors.orange,
              () {
                if (widget.onTabChange != null) {
                  widget.onTabChange!(1); // Cambiar a pestaña de clientes
                }
              },
            ),
            _buildAccesoRapido(
              "Próximos Pagos",
              Icons.schedule,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProximosPagosPage(db: widget.db),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccesoRapido(String titulo, IconData icono, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionGraficas(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Análisis y gráficas",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Gráficas próximamente",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Aquí se mostrarán gráficas del API",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}