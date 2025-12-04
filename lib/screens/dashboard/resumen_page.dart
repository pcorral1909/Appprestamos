import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:prestamos_app/database/app_database.dart';
import '../clientes/clientes_page.dart';
import '../prestamos/proximos_pagos_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:rxdart/rxdart.dart'; // agregar arriba con los imports

class ResumenPage extends StatefulWidget {
  final AppDatabase db;
  const ResumenPage({super.key, required this.db});

  @override
  _ResumenPageState createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  Future<Map<String, double>> _calcularEstadisticas() async {
    final ahora = DateTime.now();

    // Rango de la quincena actual
    final inicioQuincena = ahora.day <= 15
        ? DateTime(ahora.year, ahora.month, 1)
        : DateTime(ahora.year, ahora.month, 16);

    final finQuincena = ahora.day <= 15
        ? DateTime(ahora.year, ahora.month, 15, 23, 59, 59)
        : DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

    // Rango del mes actual
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

    // 1) totalPrestado (+) y totalAbonosCapital por prestamo (para deuda total)
    final totalPrestadoRow = await widget.db.customSelect('''
    SELECT COALESCE(SUM(monto),0) as totalPrestado
    FROM prestamos
    ''').getSingle();

    final totalPrestado =
        (totalPrestadoRow.data['totalPrestado'] as num?)?.toDouble() ?? 0.0;

    // 2) interesesGanados (suma de abonos.tipo = 'interes')
    final interesesRow = await widget.db.customSelect('''
    SELECT COALESCE(SUM(monto),0) as total
    FROM abonos
    WHERE tipo = 'interes'
    ''').getSingle();

    final interesesGanados =
        (interesesRow.data['total'] as num?)?.toDouble() ?? 0.0;

    // 3) total deuda actual (sum(prestamo.monto - SUM(abonos capital por préstamo)))
    //    Usamos LEFT JOIN a subconsulta que agrupa abonos tipo 'capital'
    final deudaRow = await widget.db.customSelect('''
    SELECT COALESCE(SUM(p.monto - COALESCE(ac.total,0)), 0) as deudaTotal
    FROM prestamos p
    LEFT JOIN (
      SELECT prestamo_id, SUM(monto) as total
      FROM abonos
      WHERE tipo = 'capital'
      GROUP BY prestamo_id
    ) ac ON ac.prestamo_id = p.id
    ''').getSingle();

    final totalDeuda = (deudaRow.data['deudaTotal'] as num?)?.toDouble() ?? 0.0;

    // 4) totalQuincena: sum de amortizaciones entre inicioQuincena y finQuincena
    //    solo para prestamos tipo 'ordinario' o 'msi' -> JOIN con prestamos
    final pagosQuincenaRow = await widget.db
        .customSelect(
          '''
    SELECT COALESCE(SUM(a.monto),0) as total
    FROM amortizaciones a
    INNER JOIN prestamos p ON p.id = a.prestamo_id
    WHERE a.fecha_pago BETWEEN ? AND ?
      AND (p.tipo_prestamo = 'ordinario' OR p.tipo_prestamo = 'msi')
    ''',
          variables: [
            Variable<DateTime>(inicioQuincena),
            Variable<DateTime>(finQuincena),
          ],
        )
        .getSingle();

    final totalQuincena =
        (pagosQuincenaRow.data['total'] as num?)?.toDouble() ?? 0.0;

    // 5) interesesPendientesMes: amortizaciones no pagadas en el mes actual
    //    pero solo para prestamos tipo 'tasa'
    final pendientesRow = await widget.db
        .customSelect(
          '''
    SELECT COALESCE(SUM(a.monto),0) as total
    FROM amortizaciones a
    INNER JOIN prestamos p ON p.id = a.prestamo_id
    WHERE a.fecha_pago BETWEEN ? AND ?
      AND a.pagado = 0
      AND p.tipo_prestamo = 'tasa'
    ''',
          variables: [
            Variable<DateTime>(inicioMes),
            Variable<DateTime>(finMes),
          ],
        )
        .getSingle();

    final interesesPendientesMes =
        (pendientesRow.data['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'totalPrestado': totalPrestado,
      'interesesGanados': interesesGanados,
      'totalDebeHoy': totalDeuda,
      'totalQuincena': totalQuincena,
      'interesesPendientesMes': interesesPendientesMes,
    };
  }

  Stream<Map<String, double>> _statsStream() async* {
    // Emitimos primero los valores iniciales
    yield await _calcularEstadisticas();

    final prestamosStream = widget.db.select(widget.db.prestamos).watch();
    final amortizacionesStream = widget.db
        .select(widget.db.amortizaciones)
        .watch();
    final abonosStream = widget.db.select(widget.db.abonos).watch();

    final merged = MergeStream([
      prestamosStream,
      amortizacionesStream,
      abonosStream,
    ]);

    await for (final _ in merged) {
      // cada vez que haya un cambio en cualquiera de las tres tablas:
      yield await _calcularEstadisticas();
    }
  }

  // Tarjeta con animación
  Widget _animatedCard(String titulo, double valor, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 150)),
      tween: Tween(begin: 0, end: 1),
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(titulo),
          trailing: Text(
            "\$${valor.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Pie Chart animado
  Widget _buildPieChart(
    double totalPrestado,
    double interesesGanados,
    double totalDebeHoy,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) {
        return PieChart(
          dataMap: {
            "Prestado": totalPrestado * value,
            "Intereses": interesesGanados * value,
            "Te deben": totalDebeHoy * value,
          },
          chartRadius: MediaQuery.of(context).size.width * 0.35,
          colorList: const [Colors.blue, Colors.green, Colors.orange],
          legendOptions: const LegendOptions(
            showLegends: true,
            legendPosition: LegendPosition.right,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
            decimalPlaces: 1,
          ),
          animationDuration: const Duration(milliseconds: 0),
        );
      },
    );
  }

  // ===========================
  // UI
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resumen")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menú",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text("Resumen"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ResumenPage(db: widget.db)),
                );
              },
            ),
            ListTile(
              title: const Text("Clientes"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientesPage(db: widget.db),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Próximos pagos"),
              onTap: () {
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
      ),

      body: StreamBuilder<Map<String, double>>(
        stream: _statsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error en resumen:\n${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Sin datos"));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔵 PIE CHART ANIMADO
                _buildPieChart(
                  stats['totalPrestado']!,
                  stats['interesesGanados']!,
                  stats['totalDebeHoy']!,
                ),

                const SizedBox(height: 20),

                // Tarjetas animadas
                _animatedCard("Total prestado", stats['totalPrestado']!, 0),
                _animatedCard(
                  "Intereses ganados",
                  stats['interesesGanados']!,
                  1,
                ),
                _animatedCard(
                  "Total que te deben hoy",
                  stats['totalDebeHoy']!,
                  2,
                ),
                _animatedCard(
                  "Cobro de esta quincena",
                  stats['totalQuincena']!,
                  3,
                ),
                _animatedCard(
                  "Intereses pendientes del mes",
                  stats['interesesPendientesMes']!,
                  4,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
