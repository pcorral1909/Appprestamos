import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../utils/delete_utils.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/amortizacion.dart';
import '../../domain/usecases/get_prestamos_by_cliente_usecase.dart';
import '../../domain/usecases/pagar_amortizacion_usecase.dart';
import '../../domain/usecases/abono_capital_usecase.dart';
import 'agregar_prestamo_page.dart';

class PrestamosClientePage extends StatefulWidget {
  final int clienteId;
  final String clienteNombre;

  const PrestamosClientePage({
    super.key,
    required this.clienteId,
    required this.clienteNombre,
  });

  @override
  State<PrestamosClientePage> createState() => _PrestamosClientePageState();
}

class _PrestamosClientePageState extends State<PrestamosClientePage> {
  late Future<List<Prestamo>> _prestamosFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrestamos();
  }

  void _loadPrestamos() {
    setState(() {
      _prestamosFuture = _fetchPrestamos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Préstamos - ${widget.clienteNombre}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPrestamos,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _navigateToAgregarPrestamo,
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Prestamo>>(
            future: _prestamosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando préstamos...'),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrestamos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final prestamos = snapshot.data ?? [];

              if (prestamos.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay préstamos para este cliente'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: prestamos.length,
                itemBuilder: (context, index) {
                  return _buildPrestamoCard(context, prestamos[index]);
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Procesando...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrestamoCard(BuildContext context, Prestamo prestamo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text('Préstamo #${prestamo.id}')),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deletePrestamo(prestamo.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Text('Monto: \$${prestamo.monto.toStringAsFixed(2)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrestamoInfo(prestamo),
                const SizedBox(height: 16),
                if (prestamo.permiteAbonoCapital)
                  ElevatedButton(
                    onPressed: () => _showAbonoDialog(context, prestamo),
                    child: const Text('Abono a Capital'),
                  ),
                const SizedBox(height: 16),
                const Text('Amortizaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...prestamo.amortizaciones.map((amort) => _buildAmortizacionTile(context, prestamo, amort)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestamoInfo(Prestamo prestamo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pago Quincenal: \$${prestamo.pagoQuincenal.toStringAsFixed(2)}'),
        Text('Fecha Inicio: ${DateFormat('dd/MM/yyyy').format(prestamo.fechaInicio)}'),
        Text('Fecha Fin: ${DateFormat('dd/MM/yyyy').format(prestamo.fechaFin)}'),
        Text('Tipo: ${prestamo.tipoPrestamo}'),
        Text('Meses: ${prestamo.meses}'),
      ],
    );
  }

  Widget _buildAmortizacionTile(BuildContext context, Prestamo prestamo, Amortizacion amort) {
    final now = DateTime.now();
    final isCurrentWeek = _isInCurrentWeek(amort.fechaPago, now);
    
    return ListTile(
      title: Text('Pago #${amort.numeroPago}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fecha: ${DateFormat('dd/MM/yyyy').format(amort.fechaPago)}'),
          Text('Monto: \$${amort.montoTotal.toStringAsFixed(2)}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (amort.pagado)
            const Chip(
              label: Text('Pagada', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            )
          else if (isCurrentWeek)
            const Chip(
              label: Text('Por Pagar', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          if (!amort.pagado)
            Checkbox(
              value: false,
              onChanged: (value) {
                if (value == true) {
                  _showPagoDialog(context, prestamo, amort);
                }
              },
            ),
        ],
      ),
    );
  }

  bool _isInCurrentWeek(DateTime fecha, DateTime now) {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return fecha.isAfter(startOfWeek) && fecha.isBefore(endOfWeek);
  }

  void _showPagoDialog(BuildContext context, Prestamo prestamo, Amortizacion amort) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pago'),
        content: Text('¿Pagar \$${amort.montoTotal.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              Navigator.pop(context);
              _pagarAmortizacion(prestamo.id, amort.numeroPago, amort.montoTotal);
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }

  void _showAbonoDialog(BuildContext context, Prestamo prestamo) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abono a Capital'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              final monto = double.tryParse(controller.text);
              if (monto != null && monto > 0) {
                Navigator.pop(context);
                _abonoCapital(prestamo.id, monto);
              }
            },
            child: const Text('Abonar'),
          ),
        ],
      ),
    );
  }

  Future<List<Prestamo>> _fetchPrestamos() async {
    final useCase = sl<GetPrestamosByClienteUseCase>();
    final result = await useCase(GetPrestamosByClienteParams(clienteId: widget.clienteId));
    
    return result.fold(
      (failure) {
        print('Error cargando préstamos: ${failure.message}');
        return [];
      },
      (prestamos) => prestamos,
    );
  }

  Future<void> _pagarAmortizacion(int prestamoId, int numeroPago, double monto) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = sl<PagarAmortizacionUseCase>();
      final result = await useCase(PagarAmortizacionParams(
        prestamoId: prestamoId,
        numeroPago: numeroPago,
        monto: monto,
      ));

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pago realizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPrestamos(); // Recargar datos
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _abonoCapital(int prestamoId, double monto) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = sl<AbonoCapitalUseCase>();
      final result = await useCase(AbonoCapitalParams(
        prestamoId: prestamoId,
        monto: monto,
      ));

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abono realizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPrestamos(); // Recargar datos
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAgregarPrestamo() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AgregarPrestamoPage(
          clienteId: widget.clienteId,
          clienteNombre: widget.clienteNombre,
        ),
      ),
    );
    
    if (result == true) {
      _loadPrestamos();
    }
  }

  Future<void> _deletePrestamo(int prestamoId) async {
    await DeleteUtils.deletePrestamo(context, prestamoId);
    _loadPrestamos();
  }
}