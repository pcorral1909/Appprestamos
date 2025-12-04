import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../clientes/clientes_page.dart';
import '../prestamos/proximos_pagos_page.dart';
//import '../../utils/prestamo_helper.dart'; // si usas la extensión de amortización

class DashboardPage extends StatefulWidget {
  final AppDatabase db;
  const DashboardPage({super.key, required this.db});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, double>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = _calcularEstadisticas();
  }

  Future<Map<String, double>> _calcularEstadisticas() async {
    final prestamos = await widget.db.select(widget.db.prestamos).get();

    double totalPrestado = 0;
    double totalGanancia = 0;
    double totalProximoLiquidar = 0;

    for (final p in prestamos) {
      totalPrestado += p.monto;
      totalGanancia +=
          ((p.pagoQuincenal ?? 0) * 8) -
          p.monto; // ejemplo ganancia quincenal 8 pagos
      // calcular próximos a liquidar (pagos que todavía no pasaron)
      final ahora = DateTime.now();
      final amortizacion = p.generarAmortizacion(8);
      for (final a in amortizacion) {
        if ((a['fecha'] as DateTime).isAfter(ahora)) {
          totalProximoLiquidar += a['monto'] as double;
        }
      }
    }

    return {
      'totalPrestado': totalPrestado,
      'ganancia': totalGanancia,
      'proximoLiquidar': totalProximoLiquidar,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
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
      body: FutureBuilder<Map<String, double>>(
        future: statsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCard("Total prestado", stats['totalPrestado']!),
                const SizedBox(height: 12),
                _buildCard("Ganancia estimada", stats['ganancia']!),
                const SizedBox(height: 12),
                _buildCard("Próximos a liquidar", stats['proximoLiquidar']!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String titulo, double valor) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          "\$${valor.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
