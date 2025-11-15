import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
//import 'package:prestamos_app/database/app_database.g.dart';

part 'app_database.g.dart';

// ========================================================
//  TABLA CLIENTES
// ========================================================

class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get email => text().nullable()();
  TextColumn get telefono => text().nullable()();
  DateTimeColumn get fechaRegistro =>
      dateTime().withDefault(Constant(DateTime.now()))();
}

// ========================================================
//  TABLA PRÉSTAMOS
//  🔥 Cambios agregados:
//   - Se agregó fechaPrimerPago para soportar pagos manuales
// ========================================================

class Prestamos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer()();
  RealColumn get monto => real()();
  RealColumn get pagoQuincenal => real()();
  DateTimeColumn get fechaInicio => dateTime()();

  /// 🔥 NUEVO: fecha del primer pago manual
  DateTimeColumn get fechaPrimerPago => dateTime()();

  DateTimeColumn get fechaFin => dateTime().nullable()();
}

// ========================================================
//  TABLA AMORTIZACIONES
//  🔥 NUEVA TABLA NECESARIA PARA PAGOS INDIVIDUALES
// ========================================================

class Amortizaciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prestamoId => integer()();
  RealColumn get monto => real()();
  DateTimeColumn get fechaPago => dateTime()();
  BoolColumn get pagado =>
      boolean().withDefault(const Constant(false))(); // marcado manual
}

// ========================================================
//  BASE DE DATOS PRINCIPAL
// ========================================================

@DriftDatabase(tables: [Clientes, Prestamos, Amortizaciones])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // cambiamos versión para regenerar tablas nuevas
}

// ========================================================
//  CONEXIÓN LOCAL
// ========================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'prestamos.db'));
    return NativeDatabase(file, logStatements: true);
  });
}

// ========================================================
//  🔥 MODELO NECESARIO PARA AGRUPAR PRÉSTAMO + PAGOS
// ========================================================
class PrestamoConPagos {
  final Prestamo prestamo;
  final List<Amortizacione> pagos;

  PrestamoConPagos(this.prestamo, this.pagos);
}

// ========================================================
//  🔥 MÉTODO PARA OBTENER PRÉSTAMOS + PAGOS (JOIN)
//  Esto lo usa la pantalla de detalle del cliente
// ========================================================

extension PrestamosQueries on AppDatabase {
  Stream<List<PrestamoConPagos>> watchPrestamosConPagos(int clienteId) {
    final query =
        (select(prestamos)..where((t) => t.clienteId.equals(clienteId))).join([
          leftOuterJoin(
            amortizaciones,
            amortizaciones.prestamoId.equalsExp(prestamos.id),
          ),
        ]);

    return query.watch().map((rows) {
      final mapa = <int, PrestamoConPagos>{};

      for (final row in rows) {
        final prestamo = row.readTable(prestamos);
        final pago = row.readTableOrNull(
          amortizaciones,
        ); // IMPORTANTE: correcto

        mapa.putIfAbsent(prestamo.id, () => PrestamoConPagos(prestamo, []));

        if (pago != null) {
          mapa[prestamo.id]!.pagos.add(pago);
        }
      }

      return mapa.values.toList();
    });
  }
}

// ========================================================
//  🔥 GENERADOR DE AMORTIZACIÓN (si aún lo usas)
// ========================================================
extension PrestamoHelper on Prestamo {
  List<Map<String, dynamic>> generarAmortizacion(int quincenas) {
    List<Map<String, dynamic>> lista = [];

    for (int i = 0; i < quincenas; i++) {
      final fechaPago = fechaPrimerPago.add(Duration(days: i * 15));
      lista.add({
        'fecha': fechaPago,
        'monto': pagoQuincenal,
        'pagoNumero': i + 1,
      });
    }
    return lista;
  }
}

// ========================================================
//  🔥 OBTENER PRÓXIMOS PAGOS (OPCIONAL)
// ========================================================
Future<List<Map<String, dynamic>>> obtenerProximosPagos(
  AppDatabase db, {
  int quincenas = 8,
}) async {
  final result = await db.select(db.prestamos).join([
    innerJoin(db.clientes, db.clientes.id.equalsExp(db.prestamos.clienteId)),
  ]).get();

  List<Map<String, dynamic>> pagos = [];

  for (final row in result) {
    final prestamo = row.readTable(db.prestamos);
    final cliente = row.readTable(db.clientes);

    final amortizacion = prestamo.generarAmortizacion(quincenas);

    for (final a in amortizacion) {
      pagos.add({
        'clienteId': cliente.id,
        'clienteNombre': cliente.nombre,
        'fecha': a['fecha'],
        'monto': a['monto'],
        'pagoNumero': a['pagoNumero'],
      });
    }
  }

  pagos.sort(
    (a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime),
  );

  return pagos;
}
