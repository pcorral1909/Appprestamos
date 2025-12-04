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
  RealColumn get pagoQuincenal => real().nullable()();
  DateTimeColumn get fechaInicio => dateTime()();

  /// 🔥 NUEVO: fecha del primer pago manual
  DateTimeColumn get fechaPrimerPago => dateTime().nullable()();

  DateTimeColumn get fechaFin => dateTime().nullable()();
  TextColumn get tipoPrestamo =>
      text().withDefault(const Constant('ordinario'))();
  RealColumn get interesMensual => real().nullable()();
  IntColumn get meses => integer().nullable()();
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

class Abonos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prestamoId => integer()();
  RealColumn get monto => real()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get tipo => text().nullable()(); // 'capital' | 'interes' | null
}

// ========================================================
//  BASE DE DATOS PRINCIPAL
// ========================================================

@DriftDatabase(tables: [Clientes, Prestamos, Amortizaciones, Abonos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // actualizado para nuevos campos y tablas

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(prestamos, prestamos.tipoPrestamo);
      }
      if (from < 3) {
        await m.addColumn(prestamos, prestamos.fechaPrimerPago);
      }
      if (from < 4) {
        await m.addColumn(prestamos, prestamos.interesMensual);
        await m.createTable(amortizaciones);
        await m.createTable(abonos);
      }
      if (from < 5) {
        await m.addColumn(prestamos, prestamos.meses);
      }
    },
  );
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
//  🔥 LÓGICA DE AMORTIZACIÓN PARA PRÉSTAMO TASA
// ========================================================
extension PrestamoTasaHelper on AppDatabase {
  Future<List<Map<String, dynamic>>> generarAmortizacionesTasa(
    Prestamo prestamo, {
    int meses = 6,
  }) async {
    final fechaInicio = prestamo.fechaPrimerPago ?? prestamo.fechaInicio;
    final List<Map<String, dynamic>> lista = [];
    DateTime fecha = fechaInicio;

    for (int i = 0; i < meses; i++) {
      final saldo = await calcularSaldoEnFecha(prestamo, fecha);
      final interes = saldo * (prestamo.interesMensual ?? 0) / 100;

      lista.add({
        'fecha': fecha,
        'interes': double.parse(interes.toStringAsFixed(2)),
        'saldo': double.parse(saldo.toStringAsFixed(2)),
      });

      fecha = DateTime(fecha.year, fecha.month + 1, fecha.day);
    }
    return lista;
  }

  Future<void> registrarAbonoTasa(
    int prestamoId,
    double monto,
    DateTime fecha, {
    String tipo = 'capital',
  }) async {
    await into(abonos).insert(
      AbonosCompanion.insert(
        prestamoId: prestamoId,
        monto: monto,
        fecha: fecha,
        tipo: tipo == 'capital'
            ? const Value('capital')
            : const Value('interes'),
      ),
    );
  }

  Future<double> calcularInteresEnFecha(
    Prestamo prestamo,
    DateTime fecha,
  ) async {
    final saldo = await calcularSaldoEnFecha(prestamo, fecha);
    final interes = saldo * (prestamo.interesMensual ?? 0) / 100;
    return double.parse(interes.toStringAsFixed(2));
  }

  Future<double> calcularSaldoEnFecha(Prestamo prestamo, DateTime fecha) async {
    final abonos = await customSelect(
      '''
    SELECT COALESCE(SUM(monto),0) as total 
    FROM abonos 
    WHERE prestamo_id = ? 
    AND tipo = 'capital'
    AND fecha <= ?
    ''',
      variables: [Variable<int>(prestamo.id), Variable<DateTime>(fecha)],
    ).getSingleOrNull();

    final abonoCapital = (abonos?.data['total'] as num?)?.toDouble() ?? 0.0;
    double saldo = prestamo.monto - abonoCapital;
    if (saldo < 0) saldo = 0;

    return double.parse(saldo.toStringAsFixed(2));
  }

  Future<void> generarAmortizacionTasaSiguiente(
    Prestamo prestamo,
    DateTime fechaActual,
  ) async {
    // siguiente mes manteniendo el mismo día base
    final siguiente = DateTime(
      fechaActual.year,
      fechaActual.month + 1,
      fechaActual.day,
    );

    // evitar duplicados: si ya existe, no insertar
    final existente =
        await (select(amortizaciones)..where(
              (t) =>
                  t.prestamoId.equals(prestamo.id) &
                  t.fechaPago.equals(siguiente),
            ))
            .getSingleOrNull();

    if (existente != null) return;

    final monto = await calcularInteresEnFecha(prestamo, siguiente);
    // si el monto es 0 (saldo 0) no insertar
    if (monto <= 0) {
      // si saldo 0, marcar prestamo como finalizado
      final saldo = await calcularSaldoEnFecha(prestamo, siguiente);
      if (saldo <= 0) {
        await (update(prestamos)..where((t) => t.id.equals(prestamo.id))).write(
          PrestamosCompanion(fechaFin: Value(siguiente)),
        );
      }
      return;
    }

    await into(amortizaciones).insert(
      AmortizacionesCompanion.insert(
        prestamoId: prestamo.id,
        monto: monto,
        fechaPago: siguiente,
        pagado: const Value(false),
      ),
    );
  }

  Future<void> asegurarAmortizacionInicialTasa(Prestamo prestamo) async {
    final existe = await (select(
      amortizaciones,
    )..where((t) => t.prestamoId.equals(prestamo.id))).getSingleOrNull();
    if (existe == null) {
      final fecha = prestamo.fechaPrimerPago ?? prestamo.fechaInicio;
      final monto = await calcularInteresEnFecha(prestamo, fecha);
      await into(amortizaciones).insert(
        AmortizacionesCompanion.insert(
          prestamoId: prestamo.id,
          monto: monto,
          fechaPago: fecha,
          pagado: const Value(false),
        ),
      );
    }
  }

  Future<void> asegurarAmortizacionesTasaHasta(
    Prestamo prestamo,
    DateTime hasta,
  ) async {
    if (prestamo.tipoPrestamo != 'tasa') return;
    final inicio = prestamo.fechaPrimerPago ?? prestamo.fechaInicio;

    // ventana deslizante: no generar más allá de hoy + 6 meses
    final hoy = DateTime.now();
    final maxHasta = DateTime(hoy.year, hoy.month + 6, inicio.day);

    // usar el menor de los dos (hasta solicitado vs ventana máxima)
    final limite = hasta.isAfter(maxHasta) ? maxHasta : hasta;

    DateTime cursor = inicio;
    while (!cursor.isAfter(limite)) {
      final saldo = await calcularSaldoEnFecha(prestamo, cursor);
      if (saldo <= 0) {
        // si saldo 0 o negativo, marcar fechaFin y detener
        await (update(prestamos)..where((t) => t.id.equals(prestamo.id))).write(
          PrestamosCompanion(fechaFin: Value(cursor)),
        );
        break;
      }
      final existente =
          await (select(amortizaciones)..where(
                (t) =>
                    t.prestamoId.equals(prestamo.id) &
                    t.fechaPago.equals(cursor),
              ))
              .getSingleOrNull();
      final montoNuevo = await calcularInteresEnFecha(prestamo, cursor);

      if (existente == null) {
        await into(amortizaciones).insert(
          AmortizacionesCompanion.insert(
            prestamoId: prestamo.id,
            monto: montoNuevo,
            fechaPago: cursor,
            pagado: const Value(false),
          ),
        );
      } else {
        if (!existente.pagado && (existente.monto - montoNuevo).abs() > 0.01) {
          await (update(amortizaciones)
                ..where((t) => t.id.equals(existente.id)))
              .write(AmortizacionesCompanion(monto: Value(montoNuevo)));
        }
      }

      cursor = DateTime(cursor.year, cursor.month + 1, cursor.day);
    }
  }

  Future<double> calcularInteresesGanados(int prestamoId) async {
    final result = await customSelect(
      '''
        SELECT COALESCE(SUM(monto), 0) AS total
        FROM abonos
        WHERE prestamo_id = ?
        AND tipo = 'interes'
        ''',
      variables: [Variable<int>(prestamoId)],
    ).getSingleOrNull();

    return (result?.data['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> checarLiquidacionPorCapital(
    int prestamoId,
    DateTime fecha,
  ) async {
    final p = await (select(
      prestamos,
    )..where((t) => t.id.equals(prestamoId))).getSingleOrNull();
    if (p == null || p.tipoPrestamo != 'tasa') return;
    final saldo = await calcularSaldoEnFecha(p, fecha);
    if (saldo <= 0) {
      await (update(prestamos)..where((t) => t.id.equals(p.id))).write(
        PrestamosCompanion(fechaFin: Value(fecha)),
      );
    }
  }
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
      final DateTime base = fechaPrimerPago ?? fechaInicio;
      final fechaPago = DateTime(
        base.year,
        base.month,
        base.day,
      ).add(Duration(days: i * 15));
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
    if (prestamo.tipoPrestamo == 'tasa') {
      final lista = await db.generarAmortizacionesTasa(prestamo, meses: 6);
      for (int i = 0; i < lista.length; i++) {
        final a = lista[i];
        final interes = a['interes'] as double;
        if (interes > 0) {
          pagos.add({
            'clienteId': cliente.id,
            'clienteNombre': cliente.nombre,
            'fecha': a['fecha'],
            'monto': interes,
            'pagoNumero': 'Interés',
            'tipo': 'tasa',
            'prestamoId': prestamo.id,
          });
        }
      }
    } else {
      final amortizacion = prestamo.generarAmortizacion(quincenas);
      for (final a in amortizacion) {
        pagos.add({
          'clienteId': cliente.id,
          'clienteNombre': cliente.nombre,
          'fecha': a['fecha'],
          'monto': a['monto'],
          'pagoNumero': a['pagoNumero'],
          'tipo': 'ordinario',
          'prestamoId': prestamo.id,
        });
      }
    }
  }

  pagos.sort(
    (a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime),
  );

  return pagos;
}
