import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/tipo_prestamo.dart';
import '../../data/datasources/prestamos_remote_datasource.dart';

class AgregarPrestamoPage extends StatefulWidget {
  final int clienteId;
  final String clienteNombre;

  const AgregarPrestamoPage({
    super.key,
    required this.clienteId,
    required this.clienteNombre,
  });

  @override
  State<AgregarPrestamoPage> createState() => _AgregarPrestamoPageState();
}

class _AgregarPrestamoPageState extends State<AgregarPrestamoPage> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _tasaController = TextEditingController();
  final _mesesController = TextEditingController();
  
  List<TipoPrestamo> _tiposPrestamo = [];
  TipoPrestamo? _tipoSeleccionado;
  DateTime _fechaPrimerPago = DateTime.now().add(const Duration(days: 15));
  bool _isLoading = false;
  bool _loadingTipos = true;

  @override
  void initState() {
    super.initState();
    _loadTiposPrestamo();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _tasaController.dispose();
    _mesesController.dispose();
    super.dispose();
  }

  Future<void> _loadTiposPrestamo() async {
    try {
      final dataSource = sl<PrestamosRemoteDataSource>();
      final tipos = await dataSource.getTiposPrestamo();
      setState(() {
        _tiposPrestamo = tipos.map((model) => model.toEntity()).toList();
        _loadingTipos = false;
      });
    } catch (e) {
      setState(() {
        _loadingTipos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tipos de préstamo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Préstamo - ${widget.clienteNombre}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loadingTipos
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tipo de préstamo
                      DropdownButtonFormField<TipoPrestamo>(
                        value: _tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Préstamo *',
                          border: OutlineInputBorder(),
                        ),
                        items: _tiposPrestamo.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.nombre),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoSeleccionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecciona un tipo de préstamo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Monto
                      TextFormField(
                        controller: _montoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto *',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El monto es requerido';
                          }
                          final monto = double.tryParse(value);
                          if (monto == null || monto <= 0) {
                            return 'Ingresa un monto válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Campos específicos según tipo
                      if (_tipoSeleccionado?.id == 2) ...[
                        TextFormField(
                          controller: _tasaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tasa de Interés *',
                            suffixText: '%',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La tasa es requerida';
                            }
                            final tasa = double.tryParse(value);
                            if (tasa == null || tasa < 0) {
                              return 'Ingresa una tasa válida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (_tipoSeleccionado?.id == 3) ...[
                        TextFormField(
                          controller: _mesesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Meses *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Los meses son requeridos';
                            }
                            final meses = int.tryParse(value);
                            if (meses == null || meses <= 0) {
                              return 'Ingresa un número de meses válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Fecha primer pago (solo para tipos que no sean libre)
                      if (_tipoSeleccionado?.id != 4) ...[
                        ListTile(
                          title: const Text('Fecha Primer Pago'),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaPrimerPago)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: _selectDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Crear Préstamo'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaPrimerPago,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _fechaPrimerPago = date;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dataSource = sl<PrestamosRemoteDataSource>();
        final monto = double.parse(_montoController.text);

        switch (_tipoSeleccionado!.id) {
          case 1: // Ordinario
            await dataSource.crearPrestamoOrdinario(
              widget.clienteId,
              monto,
              _fechaPrimerPago,
            );
            break;
          case 2: // Con Tasa
            final tasa = double.parse(_tasaController.text);
            await dataSource.crearPrestamoConTasa(
              widget.clienteId,
              monto,
              tasa,
              _fechaPrimerPago,
            );
            break;
          case 3: // MSI
            final meses = int.parse(_mesesController.text);
            await dataSource.crearPrestamoMSI(
              widget.clienteId,
              monto,
              meses,
              _fechaPrimerPago,
            );
            break;
          case 4: // Libre
            await dataSource.crearPrestamoLibre(widget.clienteId, monto);
            break;
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Préstamo creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}