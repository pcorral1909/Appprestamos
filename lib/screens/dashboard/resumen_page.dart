import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:prestamos_app/database/app_database.dart';
import '../clientes/clientes_page.dart';
import '../prestamos/proximos_pagos_page.dart';

class ResumenPage extends StatefulWidget {
  final AppDatabase db;
  const ResumenPage({super.key, required this.db});

  @override
  _ResumenPageState createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  Future<Map<String, double>> _calcularEstadisticas() async {
    final prestamos = await widget.db.select(widget.db.prestamos).get();

    double totalPrestado = 0;
    double totalGanancia = 0;
    double totalProximoLiquidar = 0;

    for (final p in prestamos) {
      totalPrestado += p.monto;

      final amortizaciones = await (widget.db.select(
        widget.db.amortizaciones,
      )..where((tbl) => tbl.prestamoId.equals(p.id))).get();

      final totalPagos = amortizaciones.length;

      totalGanancia += (p.pagoQuincenal * totalPagos) - p.monto;

      final ahora = DateTime.now();

      for (final pago in amortizaciones) {
        if (pago.fechaPago.isAfter(ahora)) {
          totalProximoLiquidar += pago.monto;
        }
      }
    }

    return {
      'totalPrestado': totalPrestado,
      'ganancia': totalGanancia,
      'proximoLiquidar': totalProximoLiquidar,
    };
  }

  Stream<Map<String, double>> _statsStream() async* {
    yield await _calcularEstadisticas();

    await for (final _ in widget.db.select(widget.db.prestamos).watch()) {
      yield await _calcularEstadisticas();
    }

    await for (final _ in widget.db.select(widget.db.amortizaciones).watch()) {
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
  Widget _buildPieChart(double totalPrestado, double ganancia, double proximo) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) {
        return PieChart(
          dataMap: {
            "Prestado": totalPrestado * value,
            "Ganancia": ganancia * value,
            "Próximos pagos": proximo * value,
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔵 PIE CHART ANIMADO
                _buildPieChart(
                  stats['totalPrestado']!,
                  stats['ganancia']!,
                  stats['proximoLiquidar']!,
                ),

                const SizedBox(height: 20),

                // Tarjetas animadas
                _animatedCard("Total prestado", stats['totalPrestado']!, 0),
                _animatedCard("Ganancia total", stats['ganancia']!, 1),
                _animatedCard(
                  "Próximos pagos a liquidar",
                  stats['proximoLiquidar']!,
                  2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
