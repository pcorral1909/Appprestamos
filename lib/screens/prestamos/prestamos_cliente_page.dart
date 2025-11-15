import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import 'agregar_prestamo_page.dart';

class PrestamosClientePage extends StatefulWidget {
  final AppDatabase db;
  final Cliente cliente;

  const PrestamosClientePage({
    super.key,
    required this.db,
    required this.cliente,
  });

  @override
  _PrestamosClientePageState createState() => _PrestamosClientePageState();
}

class _PrestamosClientePageState extends State<PrestamosClientePage> {
  late Stream<List<PrestamoConPagos>> prestamosStream;

  @override
  void initState() {
    super.initState();
    // ⬇️ Stream para escuchar cambios en préstamos y amortizaciones
    prestamosStream = widget.db.watchPrestamosConPagos(widget.cliente.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Préstamos de ${widget.cliente.nombre}")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AgregarPrestamoPage(db: widget.db, cliente: widget.cliente),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<PrestamoConPagos>>(
        stream: prestamosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final prestamos = snapshot.data!;

          if (prestamos.isEmpty) {
            return const Center(child: Text("No hay préstamos aún."));
          }

          return ListView.builder(
            itemCount: prestamos.length,
            itemBuilder: (_, i) {
              final p = prestamos[i];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text(
                    "Préstamo \$${p.prestamo.monto.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    "Primer pago: ${DateFormat("dd/MM/yyyy").format(p.prestamo.fechaPrimerPago)}",
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "Eliminar") {
                        // ⬇️ Eliminación individual del préstamo
                        // 1. borrar sus pagos
                        await (widget.db.delete(
                              widget.db.amortizaciones,
                            )..where((t) => t.prestamoId.equals(p.prestamo.id)))
                            .go();

                        // 2. borrar el préstamo
                        await (widget.db.delete(
                          widget.db.prestamos,
                        )..where((t) => t.id.equals(p.prestamo.id))).go();

                        setState(() {});
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "Eliminar",
                        child: Text("Eliminar préstamo"),
                      ),
                    ],
                  ),

                  children: p.pagos.map((pago) {
                    final estadoWidget = _buildEstadoPago(pago);

                    return ListTile(
                      title: Text(
                        "Pago: \$${pago.monto.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Row(
                        children: [
                          Text(DateFormat("dd/MM/yyyy").format(pago.fechaPago)),
                          const SizedBox(width: 10),
                          estadoWidget,
                        ],
                      ),

                      // marcar / desmarcar PAGADO
                      trailing: Checkbox(
                        value: pago.pagado,
                        onChanged: (v) async {
                          await widget.db
                              .update(widget.db.amortizaciones)
                              .replace(pago.copyWith(pagado: v));
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ======================================================
  // 🟢🟡🔴 WIDGET ESTADO DEL PAGO
  // ======================================================
  Widget _buildEstadoPago(Amortizacione pago) {
    final hoy = DateTime.now();

    if (pago.pagado) {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          "Pagado",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Pago en curso (hoy es entre fechaPago y fechaPago+13)
    if (hoy.isAfter(pago.fechaPago) &&
        hoy.isBefore(pago.fechaPago.add(const Duration(days: 14)))) {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          "En curso",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Próximos
    if (hoy.isBefore(pago.fechaPago)) {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          "Próximo",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Atrasado (opcional)
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        "Atrasado",
        style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
      ),
    );
  }
}
