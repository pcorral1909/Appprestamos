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
  bool _asegurado = false;

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

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final hoy = DateTime.now();
            for (final pc in prestamos) {
              if (pc.prestamo.tipoPrestamo == 'tasa') {
                final base =
                    pc.prestamo.fechaPrimerPago ?? pc.prestamo.fechaInicio;
                // ventana deslizante de 6 meses desde hoy (incluir hasta 6 meses adelante)
                final hasta = DateTime(hoy.year, hoy.month + 6, base.day);
                await widget.db.asegurarAmortizacionesTasaHasta(
                  pc.prestamo,
                  hasta,
                );
              }
            }
          });

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
                  subtitle: p.prestamo.tipoPrestamo == 'tasa'
                      ? FutureBuilder<double>(
                          future: widget.db.calcularSaldoEnFecha(
                            p.prestamo,
                            DateTime.now(),
                          ),
                          builder: (context, snapSaldo) {
                            final saldoTxt = snapSaldo.hasData
                                ? "\$${snapSaldo.data!.toStringAsFixed(2)}"
                                : "...";
                            return Text(
                              "Tasa: ${p.prestamo.interesMensual?.toStringAsFixed(2) ?? '0'}% "
                              "• Saldo: $saldoTxt "
                              "• Primer pago: ${p.prestamo.fechaPrimerPago != null ? DateFormat('dd/MM/yyyy').format(p.prestamo.fechaPrimerPago!) : 'Sin fecha'}"
                              "${p.prestamo.fechaFin != null ? ' • Liquidado' : ''}",
                            );
                          },
                        )
                      : p.prestamo.tipoPrestamo == 'msi'
                      ? Text(
                          "MSI • ${p.prestamo.meses} meses "
                          "• Pago: \$${(p.prestamo.monto / (p.prestamo.meses ?? 1)).toStringAsFixed(2)} "
                          "• Primer pago: ${p.prestamo.fechaPrimerPago != null ? DateFormat('dd/MM/yyyy').format(p.prestamo.fechaPrimerPago!) : 'Sin fecha'}",
                        )
                      : p.prestamo.tipoPrestamo == 'sin_interes'
                      ? FutureBuilder<double>(
                          future: widget.db.calcularSaldoEnFecha(
                            p.prestamo,
                            DateTime.now(),
                          ),
                          builder: (context, snapSaldo) {
                            final saldoTxt = snapSaldo.hasData
                                ? "\$${snapSaldo.data!.toStringAsFixed(2)}"
                                : "...";

                            return Text(
                              "SIN INTERÉS • Saldo: $saldoTxt "
                              "• Inicio: ${DateFormat('dd/MM/yyyy').format(p.prestamo.fechaInicio)}",
                            );
                          },
                        )
                      : Text(
                          "Primer pago: ${p.prestamo.fechaPrimerPago != null ? DateFormat('dd/MM/yyyy').format(p.prestamo.fechaPrimerPago!) : 'Sin fecha'}",
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
                      } else if (value == 'Abonar capital') {
                        final montoController = TextEditingController();
                        DateTime fecha = DateTime.now();
                        await showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('Abonar capital'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: montoController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Monto',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final monto = double.tryParse(
                                      montoController.text.trim(),
                                    );
                                    if (monto != null && monto > 0) {
                                      await widget.db.registrarAbonoTasa(
                                        p.prestamo.id,
                                        monto,
                                        fecha,
                                        tipo: 'capital',
                                      );
                                      final hoy = DateTime.now();
                                      final base =
                                          p.prestamo.fechaPrimerPago ??
                                          p.prestamo.fechaInicio;
                                      final hasta = DateTime(
                                        hoy.year,
                                        hoy.month + 1,
                                        base.day,
                                      );
                                      await widget.db
                                          .asegurarAmortizacionesTasaHasta(
                                            p.prestamo,
                                            hasta,
                                          );
                                      await widget.db
                                          .checarLiquidacionPorCapital(
                                            p.prestamo.id,
                                            fecha,
                                          );
                                      setState(() {});
                                    }
                                    if (mounted) Navigator.pop(context);
                                  },
                                  child: const Text('Guardar'),
                                ),
                              ],
                            );
                          },
                        );
                        setState(() {});
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "Eliminar",
                        child: Text("Eliminar préstamo"),
                      ),
                      const PopupMenuItem(
                        value: 'Abonar capital',
                        child: Text('Abonar capital'),
                      ),
                    ],
                  ),

                  children: p.prestamo.tipoPrestamo == 'tasa'
                      ? p.pagos
                            .where(
                              (pago) =>
                                  p.prestamo.fechaFin == null ||
                                  pago.fechaPago.isBefore(p.prestamo.fechaFin!),
                            )
                            .map((pago) {
                              final estadoWidget = _buildEstadoPago(pago);
                              return ListTile(
                                title: Text(
                                  "Interés: \$${pago.monto.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                subtitle: FutureBuilder<double>(
                                  future: widget.db.calcularSaldoEnFecha(
                                    p.prestamo,
                                    pago.fechaPago,
                                  ),
                                  builder: (context, snapSaldo) {
                                    final saldoTxt = snapSaldo.hasData
                                        ? "Saldo: \$${snapSaldo.data!.toStringAsFixed(2)}"
                                        : "Saldo: ...";
                                    return Row(
                                      children: [
                                        Text(
                                          DateFormat(
                                            "dd/MM/yyyy",
                                          ).format(pago.fechaPago),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(saldoTxt),
                                        const SizedBox(width: 10),
                                        estadoWidget,
                                      ],
                                    );
                                  },
                                ),
                                trailing: Checkbox(
                                  value: pago.pagado,
                                  // Si ya está pagado, no permitir cambios (checkbox deshabilitado)
                                  onChanged: pago.pagado
                                      ? null
                                      : (v) async {
                                          // marcamos la amortización como pagada
                                          await widget.db
                                              .update(widget.db.amortizaciones)
                                              .replace(
                                                pago.copyWith(pagado: v),
                                              );
                                          if (v == true) {
                                            // registrar abono de tipo interes y generar siguiente
                                            await widget.db.registrarAbonoTasa(
                                              p.prestamo.id,
                                              pago.monto,
                                              pago.fechaPago,
                                              tipo: 'interes',
                                            );
                                            await widget.db
                                                .generarAmortizacionTasaSiguiente(
                                                  p.prestamo,
                                                  pago.fechaPago,
                                                );
                                            // volver a asegurar la ventana de 6 meses
                                            final hoy = DateTime.now();
                                            final base =
                                                p.prestamo.fechaPrimerPago ??
                                                p.prestamo.fechaInicio;
                                            final hasta = DateTime(
                                              hoy.year,
                                              hoy.month + 6,
                                              base.day,
                                            );
                                            await widget.db
                                                .asegurarAmortizacionesTasaHasta(
                                                  p.prestamo,
                                                  hasta,
                                                );
                                          }
                                        },
                                ),
                              );
                            })
                            .toList()
                      : p.prestamo.tipoPrestamo == 'msi'
                      ? p.pagos.map((pago) {
                          return ListTile(
                            title: Text(
                              "Pago MSI: \$${pago.monto.toStringAsFixed(2)}",
                            ),
                            subtitle: Text(
                              DateFormat("dd/MM/yyyy").format(pago.fechaPago),
                            ),
                            trailing: Checkbox(
                              value: pago.pagado,
                              onChanged: (v) async {
                                await widget.db
                                    .update(widget.db.amortizaciones)
                                    .replace(pago.copyWith(pagado: v));
                              },
                            ),
                          );
                        }).toList()
                      : p.pagos.map((pago) {
                          final estadoWidget = _buildEstadoPago(pago);

                          return ListTile(
                            title: Text(
                              "Pago: \$${pago.monto.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  DateFormat(
                                    "dd/MM/yyyy",
                                  ).format(pago.fechaPago),
                                ),
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
