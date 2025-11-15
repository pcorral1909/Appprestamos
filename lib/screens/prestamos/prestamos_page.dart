import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import 'agregar_prestamo_page.dart';

class PrestamosPage extends StatefulWidget {
  final AppDatabase db;
  final Cliente cliente;

  const PrestamosPage({super.key, required this.db, required this.cliente});

  @override
  _PrestamosPageState createState() => _PrestamosPageState();
}

class _PrestamosPageState extends State<PrestamosPage> {
  late Stream<List<Prestamo>> prestamosStream;

  @override
  void initState() {
    super.initState();
    prestamosStream = (widget.db.select(
      widget.db.prestamos,
    )..where((p) => p.clienteId.equals(widget.cliente.id))).watch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Préstamos de ${widget.cliente.nombre}")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AgregarPrestamoPage(db: widget.db, cliente: widget.cliente),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Prestamo>>(
        stream: prestamosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final prestamos = snapshot.data!;
          if (prestamos.isEmpty) {
            return const Center(child: Text("No hay préstamos aún"));
          }

          return ListView.builder(
            itemCount: prestamos.length,
            itemBuilder: (_, i) {
              final p = prestamos[i];
              return ListTile(
                title: Text("Monto: \$${p.monto.toStringAsFixed(2)}"),
                subtitle: Text(
                  "Pago quincenal: \$${p.pagoQuincenal.toStringAsFixed(2)}\nInicio: ${p.fechaInicio.toLocal().toString().split(' ')[0]}",
                ),
                leading: const Icon(Icons.attach_money),
              );
            },
          );
        },
      ),
    );
  }
}
