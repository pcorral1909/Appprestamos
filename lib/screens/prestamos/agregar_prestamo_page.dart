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
  final TextEditingController _tasaController = TextEditingController();
  final TextEditingController _mesesController = TextEditingController();

  DateTime? _primerPago;
  String _tipo = 'ordinario';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nuevo préstamo de ${widget.cliente.nombre}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(
                  value: 'ordinario',
                  child: Text('Préstamo ordinario'),
                ),
                DropdownMenuItem(
                  value: 'tasa',
                  child: Text('Préstamo con tasa'),
                ),
                DropdownMenuItem(value: 'msi', child: Text('Préstamo MSI')),
                DropdownMenuItem(
                  value: 'sin_interes',
                  child: Text('Préstamo sin interés'),
                ),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? 'ordinario'),
              decoration: const InputDecoration(
                labelText: 'Tipo de préstamo',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
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
            if (_tipo == 'msi')
              TextField(
                controller: _mesesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Meses',
                  border: OutlineInputBorder(),
                ),
              ),

            if (_tipo == 'msi') const SizedBox(height: 20),

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

            if (_tipo == 'tasa')
              TextField(
                controller: _tasaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tasa mensual (%)',
                  border: OutlineInputBorder(),
                ),
              ),

            if (_tipo == 'tasa') const SizedBox(height: 20),

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

    if (_tipo == 'ordinario') {
      const totalPagos = 8;
      const costoPorMil = 175;
      final pagoQuincenal = (monto / 1000) * costoPorMil;
      final prestamoId = await widget.db
          .into(widget.db.prestamos)
          .insert(
            PrestamosCompanion.insert(
              clienteId: widget.cliente.id,
              monto: monto,
              pagoQuincenal: Value(pagoQuincenal),
              fechaInicio: DateTime.now(),
              fechaPrimerPago: Value(fechaPrimerPago),
              tipoPrestamo: const Value('ordinario'),
            ),
          );

      DateTime fechaPago = fechaPrimerPago;
      for (int i = 0; i < totalPagos; i++) {
        await widget.db
            .into(widget.db.amortizaciones)
            .insert(
              AmortizacionesCompanion.insert(
                prestamoId: prestamoId,
                monto: pagoQuincenal,
                fechaPago: fechaPago,
                pagado: const Value(false),
              ),
            );
        fechaPago = siguienteQuincena(fechaPago);
      }
      Navigator.pop(context);
      return;
    }
    if (_tipo == 'msi') {
      final meses = int.tryParse(_mesesController.text.trim());
      if (meses == null || meses <= 0) return;

      final pagoMensual = double.parse((monto / meses).toStringAsFixed(2));
      final fechaPrimerPago = _primerPago ?? DateTime.now();

      final prestamoId = await widget.db
          .into(widget.db.prestamos)
          .insert(
            PrestamosCompanion.insert(
              clienteId: widget.cliente.id,
              monto: monto,
              fechaInicio: DateTime.now(),
              fechaPrimerPago: Value(fechaPrimerPago),
              tipoPrestamo: const Value('msi'),
              meses: Value(meses),
            ),
          );

      DateTime fechaPago = fechaPrimerPago;

      for (int i = 0; i < meses; i++) {
        await widget.db
            .into(widget.db.amortizaciones)
            .insert(
              AmortizacionesCompanion.insert(
                prestamoId: prestamoId,
                monto: pagoMensual,
                fechaPago: fechaPago,
                pagado: const Value(false),
              ),
            );

        // siguiente mes
        fechaPago = DateTime(
          fechaPago.year,
          fechaPago.month + 1,
          fechaPago.day,
        );
      }

      Navigator.pop(context);
      return;
    }
    if (_tipo == 'sin_interes') {
      final prestamoId = await widget.db
          .into(widget.db.prestamos)
          .insert(
            PrestamosCompanion.insert(
              clienteId: widget.cliente.id,
              monto: monto,
              fechaInicio: DateTime.now(),
              fechaPrimerPago: Value(_primerPago),
              tipoPrestamo: const Value('sin_interes'),
            ),
          );

      Navigator.pop(context);
      return;
    }

    // TASA
    final tasa = double.tryParse(_tasaController.text.trim());
    if (tasa == null || tasa <= 0) return;

    final prestamoIdTasa = await widget.db
        .into(widget.db.prestamos)
        .insert(
          PrestamosCompanion.insert(
            clienteId: widget.cliente.id,
            monto: monto,
            fechaInicio: DateTime.now(),
            fechaPrimerPago: Value(fechaPrimerPago),
            tipoPrestamo: const Value('tasa'),
            interesMensual: Value(tasa),
          ),
        );

    final interesInicial = double.parse(
      ((monto * tasa) / 100).toStringAsFixed(2),
    );
    await widget.db
        .into(widget.db.amortizaciones)
        .insert(
          AmortizacionesCompanion.insert(
            prestamoId: prestamoIdTasa,
            monto: interesInicial,
            fechaPago: fechaPrimerPago,
            pagado: const Value(false),
          ),
        );

    final prestamoNuevo = await (widget.db.select(
      widget.db.prestamos,
    )..where((t) => t.id.equals(prestamoIdTasa))).getSingle();
    final base = prestamoNuevo.fechaPrimerPago ?? prestamoNuevo.fechaInicio;
    final hoy = DateTime.now();
    // ventana deslizante inicial: 6 meses desde hoy
    final hasta = DateTime(hoy.year, hoy.month + 6, base.day);
    await widget.db.asegurarAmortizacionesTasaHasta(prestamoNuevo, hasta);

    Navigator.pop(context);
  }

  DateTime siguienteQuincena(DateTime fecha) {
    final dia = fecha.day;
    final mes = fecha.month;
    final anio = fecha.year;

    // Si estamos del 1 al 15 → siguiente es día 16
    if (dia <= 15) {
      return DateTime(anio, mes, 16);
    }

    // Si estamos del 16 en adelante → siguiente es día 1 del siguiente mes
    final siguienteMes = mes == 12 ? 1 : mes + 1;
    final siguienteAnio = mes == 12 ? anio + 1 : anio;

    return DateTime(siguienteAnio, siguienteMes, 1);
  }
}
