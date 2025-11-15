import 'package:flutter/material.dart';
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
  // =====================================================
  //  Calcula estadísticas DIRECTAMENTE DE LA BASE DE DATOS
  // =====================================================
  Future<Map<String, double>> _calcularEstadisticas() async {
    final prestamos = await widget.db.select(widget.db.prestamos).get();

    double totalPrestado = 0;
    double totalGanancia = 0;
    double totalProximoLiquidar = 0;

    for (final p in prestamos) {
      totalPrestado += p.monto;

      // =============================
      // OBTENER PAGOS REALES (FIX)
      // =============================
      final amortizaciones = await (widget.db.select(
        widget.db.amortizaciones,
      )..where((tbl) => tbl.prestamoId.equals(p.id))).get();

      final totalPagos = amortizaciones.length;

      // Ganancia calculada
      totalGanancia += (p.pagoQuincenal * totalPagos) - p.monto;

      // Pagos futuros
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

  // =====================================================
  // STREAM AUTOMÁTICO: se actualiza cuando cambian préstamos o pagos
  // =====================================================
  Stream<Map<String, double>> _statsStream() async* {
    // Primera carga
    yield await _calcularEstadisticas();

    // Escucha cuando cambian préstamos
    await for (final _ in widget.db.select(widget.db.prestamos).watch()) {
      yield await _calcularEstadisticas();
    }

    // Escucha cuando cambian pagos
    await for (final _ in widget.db.select(widget.db.amortizaciones).watch()) {
      yield await _calcularEstadisticas();
    }
  }

  Widget _buildCard(String titulo, double valor) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          "\$${valor.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCard("Total prestado", stats['totalPrestado']!),
                _buildCard("Ganancia total", stats['ganancia']!),
                _buildCard(
                  "Próximos pagos a liquidar",
                  stats['proximoLiquidar']!,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
