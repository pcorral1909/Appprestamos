import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import 'package:drift/drift.dart' hide Column;

class AgregarPrestamoPage extends StatefulWidget {
  final AppDatabase db;
  final Cliente cliente;

  const AgregarPrestamoPage({
    super.key,
    required this.db,
    required this.cliente,
  });

  @override
  _AgregarPrestamoPageState createState() => _AgregarPrestamoPageState();
}

class _AgregarPrestamoPageState extends State<AgregarPrestamoPage> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _primerPagoController = TextEditingController();

  DateTime? _primerPago;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuevo préstamo de ${widget.cliente.nombre}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // MONTO
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto del préstamo",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // FECHA PRIMER PAGO
            TextField(
              controller: _primerPagoController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Fecha del primer pago",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final hoy = DateTime.now();

                final fecha = await showDatePicker(
                  context: context,
                  initialDate: hoy,
                  firstDate: hoy.subtract(const Duration(days: 120)),
                  lastDate: hoy.add(const Duration(days: 365)),
                );

                if (fecha != null) {
                  setState(() {
                    _primerPago = fecha;
                    _primerPagoController.text = DateFormat(
                      "dd/MM/yyyy",
                    ).format(fecha);
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _guardarPrestamo,
              child: const Text("Guardar préstamo"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarPrestamo() async {
    // Validar monto
    final monto = double.tryParse(_montoController.text.trim());
    if (monto == null || monto <= 0) return;

    // Fecha primer pago
    final fechaPrimerPago = _primerPago ?? DateTime.now();

    const totalPagos = 8;
    const costoPorMil = 175; // lo que pagan por 1000 en cada quincena

    final pagoQuincenal = (monto / 1000) * costoPorMil;

    // INSERTAR PRÉSTAMO
    final prestamoId = await widget.db
        .into(widget.db.prestamos)
        .insert(
          PrestamosCompanion.insert(
            clienteId: widget.cliente.id,
            monto: monto,
            pagoQuincenal: pagoQuincenal,
            fechaInicio: DateTime.now(),
            fechaPrimerPago: fechaPrimerPago,
          ),
        );

    // GENERAR PAGOS QUINCENALES
    DateTime fechaPago = fechaPrimerPago;

    for (int i = 0; i < totalPagos; i++) {
      await widget.db
          .into(widget.db.amortizaciones)
          .insert(
            AmortizacionesCompanion.insert(
              prestamoId: prestamoId,
              monto: pagoQuincenal,
              fechaPago: fechaPago,
              pagado: const Value(false), // ESTA SÍ REQUIERE VALUE()
            ),
          );

      fechaPago = fechaPago.add(const Duration(days: 14));
    }

    Navigator.pop(context);
  }
}
