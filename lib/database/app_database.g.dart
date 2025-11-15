// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaRegistroMeta = const VerificationMeta(
    'fechaRegistro',
  );
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>(
        'fecha_registro',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: Constant(DateTime.now()),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    email,
    telefono,
    fechaRegistro,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
        _fechaRegistroMeta,
        fechaRegistro.isAcceptableOrUnknown(
          data['fecha_registro']!,
          _fechaRegistroMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      fechaRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_registro'],
      )!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String nombre;
  final String? email;
  final String? telefono;
  final DateTime fechaRegistro;
  const Cliente({
    required this.id,
    required this.nombre,
    this.email,
    this.telefono,
    required this.fechaRegistro,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory Cliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      email: serializer.fromJson<String?>(json['email']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'email': serializer.toJson<String?>(email),
      'telefono': serializer.toJson<String?>(telefono),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    Value<String?> email = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    DateTime? fechaRegistro,
  }) => Cliente(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    email: email.present ? email.value : this.email,
    telefono: telefono.present ? telefono.value : this.telefono,
    fechaRegistro: fechaRegistro ?? this.fechaRegistro,
  );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      email: data.email.present ? data.email.value : this.email,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('telefono: $telefono, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, email, telefono, fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.email == this.email &&
          other.telefono == this.telefono &&
          other.fechaRegistro == this.fechaRegistro);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> email;
  final Value<String?> telefono;
  final Value<DateTime> fechaRegistro;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.email = const Value.absent(),
    this.telefono = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.email = const Value.absent(),
    this.telefono = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? email,
    Expression<String>? telefono,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  ClientesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? email,
    Value<String?>? telefono,
    Value<DateTime>? fechaRegistro,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('telefono: $telefono, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $PrestamosTable extends Prestamos
    with TableInfo<$PrestamosTable, Prestamo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrestamosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagoQuincenalMeta = const VerificationMeta(
    'pagoQuincenal',
  );
  @override
  late final GeneratedColumn<double> pagoQuincenal = GeneratedColumn<double>(
    'pago_quincenal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaInicioMeta = const VerificationMeta(
    'fechaInicio',
  );
  @override
  late final GeneratedColumn<DateTime> fechaInicio = GeneratedColumn<DateTime>(
    'fecha_inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaPrimerPagoMeta = const VerificationMeta(
    'fechaPrimerPago',
  );
  @override
  late final GeneratedColumn<DateTime> fechaPrimerPago =
      GeneratedColumn<DateTime>(
        'fecha_primer_pago',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fechaFinMeta = const VerificationMeta(
    'fechaFin',
  );
  @override
  late final GeneratedColumn<DateTime> fechaFin = GeneratedColumn<DateTime>(
    'fecha_fin',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    monto,
    pagoQuincenal,
    fechaInicio,
    fechaPrimerPago,
    fechaFin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prestamos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prestamo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('pago_quincenal')) {
      context.handle(
        _pagoQuincenalMeta,
        pagoQuincenal.isAcceptableOrUnknown(
          data['pago_quincenal']!,
          _pagoQuincenalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pagoQuincenalMeta);
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
        _fechaInicioMeta,
        fechaInicio.isAcceptableOrUnknown(
          data['fecha_inicio']!,
          _fechaInicioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaInicioMeta);
    }
    if (data.containsKey('fecha_primer_pago')) {
      context.handle(
        _fechaPrimerPagoMeta,
        fechaPrimerPago.isAcceptableOrUnknown(
          data['fecha_primer_pago']!,
          _fechaPrimerPagoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaPrimerPagoMeta);
    }
    if (data.containsKey('fecha_fin')) {
      context.handle(
        _fechaFinMeta,
        fechaFin.isAcceptableOrUnknown(data['fecha_fin']!, _fechaFinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prestamo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prestamo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      pagoQuincenal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pago_quincenal'],
      )!,
      fechaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_inicio'],
      )!,
      fechaPrimerPago: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_primer_pago'],
      )!,
      fechaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_fin'],
      ),
    );
  }

  @override
  $PrestamosTable createAlias(String alias) {
    return $PrestamosTable(attachedDatabase, alias);
  }
}

class Prestamo extends DataClass implements Insertable<Prestamo> {
  final int id;
  final int clienteId;
  final double monto;
  final double pagoQuincenal;
  final DateTime fechaInicio;

  /// 🔥 NUEVO: fecha del primer pago manual
  final DateTime fechaPrimerPago;
  final DateTime? fechaFin;
  const Prestamo({
    required this.id,
    required this.clienteId,
    required this.monto,
    required this.pagoQuincenal,
    required this.fechaInicio,
    required this.fechaPrimerPago,
    this.fechaFin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['monto'] = Variable<double>(monto);
    map['pago_quincenal'] = Variable<double>(pagoQuincenal);
    map['fecha_inicio'] = Variable<DateTime>(fechaInicio);
    map['fecha_primer_pago'] = Variable<DateTime>(fechaPrimerPago);
    if (!nullToAbsent || fechaFin != null) {
      map['fecha_fin'] = Variable<DateTime>(fechaFin);
    }
    return map;
  }

  PrestamosCompanion toCompanion(bool nullToAbsent) {
    return PrestamosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      monto: Value(monto),
      pagoQuincenal: Value(pagoQuincenal),
      fechaInicio: Value(fechaInicio),
      fechaPrimerPago: Value(fechaPrimerPago),
      fechaFin: fechaFin == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaFin),
    );
  }

  factory Prestamo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prestamo(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      monto: serializer.fromJson<double>(json['monto']),
      pagoQuincenal: serializer.fromJson<double>(json['pagoQuincenal']),
      fechaInicio: serializer.fromJson<DateTime>(json['fechaInicio']),
      fechaPrimerPago: serializer.fromJson<DateTime>(json['fechaPrimerPago']),
      fechaFin: serializer.fromJson<DateTime?>(json['fechaFin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'monto': serializer.toJson<double>(monto),
      'pagoQuincenal': serializer.toJson<double>(pagoQuincenal),
      'fechaInicio': serializer.toJson<DateTime>(fechaInicio),
      'fechaPrimerPago': serializer.toJson<DateTime>(fechaPrimerPago),
      'fechaFin': serializer.toJson<DateTime?>(fechaFin),
    };
  }

  Prestamo copyWith({
    int? id,
    int? clienteId,
    double? monto,
    double? pagoQuincenal,
    DateTime? fechaInicio,
    DateTime? fechaPrimerPago,
    Value<DateTime?> fechaFin = const Value.absent(),
  }) => Prestamo(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    monto: monto ?? this.monto,
    pagoQuincenal: pagoQuincenal ?? this.pagoQuincenal,
    fechaInicio: fechaInicio ?? this.fechaInicio,
    fechaPrimerPago: fechaPrimerPago ?? this.fechaPrimerPago,
    fechaFin: fechaFin.present ? fechaFin.value : this.fechaFin,
  );
  Prestamo copyWithCompanion(PrestamosCompanion data) {
    return Prestamo(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      monto: data.monto.present ? data.monto.value : this.monto,
      pagoQuincenal: data.pagoQuincenal.present
          ? data.pagoQuincenal.value
          : this.pagoQuincenal,
      fechaInicio: data.fechaInicio.present
          ? data.fechaInicio.value
          : this.fechaInicio,
      fechaPrimerPago: data.fechaPrimerPago.present
          ? data.fechaPrimerPago.value
          : this.fechaPrimerPago,
      fechaFin: data.fechaFin.present ? data.fechaFin.value : this.fechaFin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prestamo(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('monto: $monto, ')
          ..write('pagoQuincenal: $pagoQuincenal, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaPrimerPago: $fechaPrimerPago, ')
          ..write('fechaFin: $fechaFin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    monto,
    pagoQuincenal,
    fechaInicio,
    fechaPrimerPago,
    fechaFin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prestamo &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.monto == this.monto &&
          other.pagoQuincenal == this.pagoQuincenal &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaPrimerPago == this.fechaPrimerPago &&
          other.fechaFin == this.fechaFin);
}

class PrestamosCompanion extends UpdateCompanion<Prestamo> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<double> monto;
  final Value<double> pagoQuincenal;
  final Value<DateTime> fechaInicio;
  final Value<DateTime> fechaPrimerPago;
  final Value<DateTime?> fechaFin;
  const PrestamosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.monto = const Value.absent(),
    this.pagoQuincenal = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaPrimerPago = const Value.absent(),
    this.fechaFin = const Value.absent(),
  });
  PrestamosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required double monto,
    required double pagoQuincenal,
    required DateTime fechaInicio,
    required DateTime fechaPrimerPago,
    this.fechaFin = const Value.absent(),
  }) : clienteId = Value(clienteId),
       monto = Value(monto),
       pagoQuincenal = Value(pagoQuincenal),
       fechaInicio = Value(fechaInicio),
       fechaPrimerPago = Value(fechaPrimerPago);
  static Insertable<Prestamo> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<double>? monto,
    Expression<double>? pagoQuincenal,
    Expression<DateTime>? fechaInicio,
    Expression<DateTime>? fechaPrimerPago,
    Expression<DateTime>? fechaFin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (monto != null) 'monto': monto,
      if (pagoQuincenal != null) 'pago_quincenal': pagoQuincenal,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaPrimerPago != null) 'fecha_primer_pago': fechaPrimerPago,
      if (fechaFin != null) 'fecha_fin': fechaFin,
    });
  }

  PrestamosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<double>? monto,
    Value<double>? pagoQuincenal,
    Value<DateTime>? fechaInicio,
    Value<DateTime>? fechaPrimerPago,
    Value<DateTime?>? fechaFin,
  }) {
    return PrestamosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      monto: monto ?? this.monto,
      pagoQuincenal: pagoQuincenal ?? this.pagoQuincenal,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaPrimerPago: fechaPrimerPago ?? this.fechaPrimerPago,
      fechaFin: fechaFin ?? this.fechaFin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (pagoQuincenal.present) {
      map['pago_quincenal'] = Variable<double>(pagoQuincenal.value);
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<DateTime>(fechaInicio.value);
    }
    if (fechaPrimerPago.present) {
      map['fecha_primer_pago'] = Variable<DateTime>(fechaPrimerPago.value);
    }
    if (fechaFin.present) {
      map['fecha_fin'] = Variable<DateTime>(fechaFin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrestamosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('monto: $monto, ')
          ..write('pagoQuincenal: $pagoQuincenal, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaPrimerPago: $fechaPrimerPago, ')
          ..write('fechaFin: $fechaFin')
          ..write(')'))
        .toString();
  }
}

class $AmortizacionesTable extends Amortizaciones
    with TableInfo<$AmortizacionesTable, Amortizacione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AmortizacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _prestamoIdMeta = const VerificationMeta(
    'prestamoId',
  );
  @override
  late final GeneratedColumn<int> prestamoId = GeneratedColumn<int>(
    'prestamo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaPagoMeta = const VerificationMeta(
    'fechaPago',
  );
  @override
  late final GeneratedColumn<DateTime> fechaPago = GeneratedColumn<DateTime>(
    'fecha_pago',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagadoMeta = const VerificationMeta('pagado');
  @override
  late final GeneratedColumn<bool> pagado = GeneratedColumn<bool>(
    'pagado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pagado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prestamoId,
    monto,
    fechaPago,
    pagado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'amortizaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Amortizacione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prestamo_id')) {
      context.handle(
        _prestamoIdMeta,
        prestamoId.isAcceptableOrUnknown(data['prestamo_id']!, _prestamoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_prestamoIdMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('fecha_pago')) {
      context.handle(
        _fechaPagoMeta,
        fechaPago.isAcceptableOrUnknown(data['fecha_pago']!, _fechaPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaPagoMeta);
    }
    if (data.containsKey('pagado')) {
      context.handle(
        _pagadoMeta,
        pagado.isAcceptableOrUnknown(data['pagado']!, _pagadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Amortizacione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Amortizacione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prestamoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prestamo_id'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      fechaPago: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_pago'],
      )!,
      pagado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pagado'],
      )!,
    );
  }

  @override
  $AmortizacionesTable createAlias(String alias) {
    return $AmortizacionesTable(attachedDatabase, alias);
  }
}

class Amortizacione extends DataClass implements Insertable<Amortizacione> {
  final int id;
  final int prestamoId;
  final double monto;
  final DateTime fechaPago;
  final bool pagado;
  const Amortizacione({
    required this.id,
    required this.prestamoId,
    required this.monto,
    required this.fechaPago,
    required this.pagado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prestamo_id'] = Variable<int>(prestamoId);
    map['monto'] = Variable<double>(monto);
    map['fecha_pago'] = Variable<DateTime>(fechaPago);
    map['pagado'] = Variable<bool>(pagado);
    return map;
  }

  AmortizacionesCompanion toCompanion(bool nullToAbsent) {
    return AmortizacionesCompanion(
      id: Value(id),
      prestamoId: Value(prestamoId),
      monto: Value(monto),
      fechaPago: Value(fechaPago),
      pagado: Value(pagado),
    );
  }

  factory Amortizacione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Amortizacione(
      id: serializer.fromJson<int>(json['id']),
      prestamoId: serializer.fromJson<int>(json['prestamoId']),
      monto: serializer.fromJson<double>(json['monto']),
      fechaPago: serializer.fromJson<DateTime>(json['fechaPago']),
      pagado: serializer.fromJson<bool>(json['pagado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prestamoId': serializer.toJson<int>(prestamoId),
      'monto': serializer.toJson<double>(monto),
      'fechaPago': serializer.toJson<DateTime>(fechaPago),
      'pagado': serializer.toJson<bool>(pagado),
    };
  }

  Amortizacione copyWith({
    int? id,
    int? prestamoId,
    double? monto,
    DateTime? fechaPago,
    bool? pagado,
  }) => Amortizacione(
    id: id ?? this.id,
    prestamoId: prestamoId ?? this.prestamoId,
    monto: monto ?? this.monto,
    fechaPago: fechaPago ?? this.fechaPago,
    pagado: pagado ?? this.pagado,
  );
  Amortizacione copyWithCompanion(AmortizacionesCompanion data) {
    return Amortizacione(
      id: data.id.present ? data.id.value : this.id,
      prestamoId: data.prestamoId.present
          ? data.prestamoId.value
          : this.prestamoId,
      monto: data.monto.present ? data.monto.value : this.monto,
      fechaPago: data.fechaPago.present ? data.fechaPago.value : this.fechaPago,
      pagado: data.pagado.present ? data.pagado.value : this.pagado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Amortizacione(')
          ..write('id: $id, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('monto: $monto, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('pagado: $pagado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, prestamoId, monto, fechaPago, pagado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Amortizacione &&
          other.id == this.id &&
          other.prestamoId == this.prestamoId &&
          other.monto == this.monto &&
          other.fechaPago == this.fechaPago &&
          other.pagado == this.pagado);
}

class AmortizacionesCompanion extends UpdateCompanion<Amortizacione> {
  final Value<int> id;
  final Value<int> prestamoId;
  final Value<double> monto;
  final Value<DateTime> fechaPago;
  final Value<bool> pagado;
  const AmortizacionesCompanion({
    this.id = const Value.absent(),
    this.prestamoId = const Value.absent(),
    this.monto = const Value.absent(),
    this.fechaPago = const Value.absent(),
    this.pagado = const Value.absent(),
  });
  AmortizacionesCompanion.insert({
    this.id = const Value.absent(),
    required int prestamoId,
    required double monto,
    required DateTime fechaPago,
    this.pagado = const Value.absent(),
  }) : prestamoId = Value(prestamoId),
       monto = Value(monto),
       fechaPago = Value(fechaPago);
  static Insertable<Amortizacione> custom({
    Expression<int>? id,
    Expression<int>? prestamoId,
    Expression<double>? monto,
    Expression<DateTime>? fechaPago,
    Expression<bool>? pagado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prestamoId != null) 'prestamo_id': prestamoId,
      if (monto != null) 'monto': monto,
      if (fechaPago != null) 'fecha_pago': fechaPago,
      if (pagado != null) 'pagado': pagado,
    });
  }

  AmortizacionesCompanion copyWith({
    Value<int>? id,
    Value<int>? prestamoId,
    Value<double>? monto,
    Value<DateTime>? fechaPago,
    Value<bool>? pagado,
  }) {
    return AmortizacionesCompanion(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      monto: monto ?? this.monto,
      fechaPago: fechaPago ?? this.fechaPago,
      pagado: pagado ?? this.pagado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prestamoId.present) {
      map['prestamo_id'] = Variable<int>(prestamoId.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (fechaPago.present) {
      map['fecha_pago'] = Variable<DateTime>(fechaPago.value);
    }
    if (pagado.present) {
      map['pagado'] = Variable<bool>(pagado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AmortizacionesCompanion(')
          ..write('id: $id, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('monto: $monto, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('pagado: $pagado')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $PrestamosTable prestamos = $PrestamosTable(this);
  late final $AmortizacionesTable amortizaciones = $AmortizacionesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clientes,
    prestamos,
    amortizaciones,
  ];
}

typedef $$ClientesTableCreateCompanionBuilder =
    ClientesCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> email,
      Value<String?> telefono,
      Value<DateTime> fechaRegistro,
    });
typedef $$ClientesTableUpdateCompanionBuilder =
    ClientesCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> email,
      Value<String?> telefono,
      Value<DateTime> fechaRegistro,
    });

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => column,
  );
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          Cliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
          Cliente,
          PrefetchHooks Function()
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<DateTime> fechaRegistro = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                nombre: nombre,
                email: email,
                telefono: telefono,
                fechaRegistro: fechaRegistro,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> email = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<DateTime> fechaRegistro = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                nombre: nombre,
                email: email,
                telefono: telefono,
                fechaRegistro: fechaRegistro,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      Cliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
      Cliente,
      PrefetchHooks Function()
    >;
typedef $$PrestamosTableCreateCompanionBuilder =
    PrestamosCompanion Function({
      Value<int> id,
      required int clienteId,
      required double monto,
      required double pagoQuincenal,
      required DateTime fechaInicio,
      required DateTime fechaPrimerPago,
      Value<DateTime?> fechaFin,
    });
typedef $$PrestamosTableUpdateCompanionBuilder =
    PrestamosCompanion Function({
      Value<int> id,
      Value<int> clienteId,
      Value<double> monto,
      Value<double> pagoQuincenal,
      Value<DateTime> fechaInicio,
      Value<DateTime> fechaPrimerPago,
      Value<DateTime?> fechaFin,
    });

class $$PrestamosTableFilterComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pagoQuincenal => $composableBuilder(
    column: $table.pagoQuincenal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaPrimerPago => $composableBuilder(
    column: $table.fechaPrimerPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrestamosTableOrderingComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pagoQuincenal => $composableBuilder(
    column: $table.pagoQuincenal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaPrimerPago => $composableBuilder(
    column: $table.fechaPrimerPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrestamosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<double> get pagoQuincenal => $composableBuilder(
    column: $table.pagoQuincenal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaPrimerPago => $composableBuilder(
    column: $table.fechaPrimerPago,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaFin =>
      $composableBuilder(column: $table.fechaFin, builder: (column) => column);
}

class $$PrestamosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrestamosTable,
          Prestamo,
          $$PrestamosTableFilterComposer,
          $$PrestamosTableOrderingComposer,
          $$PrestamosTableAnnotationComposer,
          $$PrestamosTableCreateCompanionBuilder,
          $$PrestamosTableUpdateCompanionBuilder,
          (Prestamo, BaseReferences<_$AppDatabase, $PrestamosTable, Prestamo>),
          Prestamo,
          PrefetchHooks Function()
        > {
  $$PrestamosTableTableManager(_$AppDatabase db, $PrestamosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrestamosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrestamosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrestamosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<double> pagoQuincenal = const Value.absent(),
                Value<DateTime> fechaInicio = const Value.absent(),
                Value<DateTime> fechaPrimerPago = const Value.absent(),
                Value<DateTime?> fechaFin = const Value.absent(),
              }) => PrestamosCompanion(
                id: id,
                clienteId: clienteId,
                monto: monto,
                pagoQuincenal: pagoQuincenal,
                fechaInicio: fechaInicio,
                fechaPrimerPago: fechaPrimerPago,
                fechaFin: fechaFin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required double monto,
                required double pagoQuincenal,
                required DateTime fechaInicio,
                required DateTime fechaPrimerPago,
                Value<DateTime?> fechaFin = const Value.absent(),
              }) => PrestamosCompanion.insert(
                id: id,
                clienteId: clienteId,
                monto: monto,
                pagoQuincenal: pagoQuincenal,
                fechaInicio: fechaInicio,
                fechaPrimerPago: fechaPrimerPago,
                fechaFin: fechaFin,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrestamosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrestamosTable,
      Prestamo,
      $$PrestamosTableFilterComposer,
      $$PrestamosTableOrderingComposer,
      $$PrestamosTableAnnotationComposer,
      $$PrestamosTableCreateCompanionBuilder,
      $$PrestamosTableUpdateCompanionBuilder,
      (Prestamo, BaseReferences<_$AppDatabase, $PrestamosTable, Prestamo>),
      Prestamo,
      PrefetchHooks Function()
    >;
typedef $$AmortizacionesTableCreateCompanionBuilder =
    AmortizacionesCompanion Function({
      Value<int> id,
      required int prestamoId,
      required double monto,
      required DateTime fechaPago,
      Value<bool> pagado,
    });
typedef $$AmortizacionesTableUpdateCompanionBuilder =
    AmortizacionesCompanion Function({
      Value<int> id,
      Value<int> prestamoId,
      Value<double> monto,
      Value<DateTime> fechaPago,
      Value<bool> pagado,
    });

class $$AmortizacionesTableFilterComposer
    extends Composer<_$AppDatabase, $AmortizacionesTable> {
  $$AmortizacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prestamoId => $composableBuilder(
    column: $table.prestamoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaPago => $composableBuilder(
    column: $table.fechaPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pagado => $composableBuilder(
    column: $table.pagado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AmortizacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $AmortizacionesTable> {
  $$AmortizacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prestamoId => $composableBuilder(
    column: $table.prestamoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaPago => $composableBuilder(
    column: $table.fechaPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pagado => $composableBuilder(
    column: $table.pagado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AmortizacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AmortizacionesTable> {
  $$AmortizacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get prestamoId => $composableBuilder(
    column: $table.prestamoId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaPago =>
      $composableBuilder(column: $table.fechaPago, builder: (column) => column);

  GeneratedColumn<bool> get pagado =>
      $composableBuilder(column: $table.pagado, builder: (column) => column);
}

class $$AmortizacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AmortizacionesTable,
          Amortizacione,
          $$AmortizacionesTableFilterComposer,
          $$AmortizacionesTableOrderingComposer,
          $$AmortizacionesTableAnnotationComposer,
          $$AmortizacionesTableCreateCompanionBuilder,
          $$AmortizacionesTableUpdateCompanionBuilder,
          (
            Amortizacione,
            BaseReferences<_$AppDatabase, $AmortizacionesTable, Amortizacione>,
          ),
          Amortizacione,
          PrefetchHooks Function()
        > {
  $$AmortizacionesTableTableManager(
    _$AppDatabase db,
    $AmortizacionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AmortizacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AmortizacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AmortizacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> prestamoId = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<DateTime> fechaPago = const Value.absent(),
                Value<bool> pagado = const Value.absent(),
              }) => AmortizacionesCompanion(
                id: id,
                prestamoId: prestamoId,
                monto: monto,
                fechaPago: fechaPago,
                pagado: pagado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int prestamoId,
                required double monto,
                required DateTime fechaPago,
                Value<bool> pagado = const Value.absent(),
              }) => AmortizacionesCompanion.insert(
                id: id,
                prestamoId: prestamoId,
                monto: monto,
                fechaPago: fechaPago,
                pagado: pagado,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AmortizacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AmortizacionesTable,
      Amortizacione,
      $$AmortizacionesTableFilterComposer,
      $$AmortizacionesTableOrderingComposer,
      $$AmortizacionesTableAnnotationComposer,
      $$AmortizacionesTableCreateCompanionBuilder,
      $$AmortizacionesTableUpdateCompanionBuilder,
      (
        Amortizacione,
        BaseReferences<_$AppDatabase, $AmortizacionesTable, Amortizacione>,
      ),
      Amortizacione,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$PrestamosTableTableManager get prestamos =>
      $$PrestamosTableTableManager(_db, _db.prestamos);
  $$AmortizacionesTableTableManager get amortizaciones =>
      $$AmortizacionesTableTableManager(_db, _db.amortizaciones);
}
