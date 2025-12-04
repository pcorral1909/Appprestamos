import 'package:flutter/material.dart';
import '../../database/app_database.dart';
//import '../../utils/prestamo_helper.dart'; // Si usas archivo separado

class ProximosPagosPage extends StatefulWidget {
  final AppDatabase db;
  const ProximosPagosPage({super.key, required this.db});

  @override
  _ProximosPagosPageState createState() => _ProximosPagosPageState();
}

class _ProximosPagosPageState extends State<ProximosPagosPage> {
  late Future<List<Map<String, dynamic>>> pagosFuture;

  @override
  void initState() {
    super.initState();
    pagosFuture = obtenerProximosPagos(widget.db);
  }

  String _nombreMes(int mes) {
    const nombres = [
      '', // para que enero sea índice 1
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return nombres[mes];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Próximos pagos")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pagosFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final pagos = snapshot.data!;
          if (pagos.isEmpty)
            return const Center(child: Text("No hay pagos pendientes"));

          return ListView.builder(
            itemCount: pagos.length,
            itemBuilder: (_, i) {
              final pago = pagos[i];
              final fecha = pago['fecha'] as DateTime;
              return ListTile(
                leading: Text(
                  pago['tipo'] == 'tasa'
                      ? 'Interés'
                      : "Pago ${pago['pagoNumero']}",
                ),
                title: Text(
                  "${pago['clienteNombre']} - \$${pago['monto'].toStringAsFixed(2)}",
                ),
                subtitle: pago['tipo'] == 'tasa'
                    ? FutureBuilder<Prestamo>(
                        future: (widget.db.select(widget.db.prestamos)
                              ..where((t) => t.id.equals(pago['prestamoId'] as int)))
                            .getSingle(),
                        builder: (context, snapP) {
                          if (!snapP.hasData) {
                            return Text(
                              "${fecha.day.toString().padLeft(2, '0')} ${_nombreMes(fecha.month)} ${fecha.year} • Saldo: ...",
                            );
                          }
                          return FutureBuilder<double>(
                            future: widget.db.calcularSaldoEnFecha(snapP.data!, fecha),
                            builder: (context, snapSaldo) {
                              final saldoTxt = snapSaldo.hasData
                                  ? "\$${snapSaldo.data!.toStringAsFixed(2)}"
                                  : "...";
                              return Text(
                                "${fecha.day.toString().padLeft(2, '0')} ${_nombreMes(fecha.month)} ${fecha.year} • Saldo: $saldoTxt",
                              );
                            },
                          );
                        },
                      )
                    : Text(
                        "${fecha.day.toString().padLeft(2, '0')} ${_nombreMes(fecha.month)} ${fecha.year}",
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
