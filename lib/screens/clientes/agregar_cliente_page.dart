import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import 'package:drift/drift.dart' hide Column;

class AgregarClientePage extends StatefulWidget {
  final AppDatabase db;
  final Cliente? cliente; // <-- Nota el singular y el tipo correcto

  const AgregarClientePage({super.key, required this.db, this.cliente});

  @override
  _AgregarClientePageState createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends State<AgregarClientePage> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nombreController.text = widget.cliente!.nombre; // rellena el formulario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre del cliente",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final nombre = _nombreController.text.trim();
                if (nombre.isEmpty) return;

                if (widget.cliente != null) {
                  // EDITAR cliente existente
                  await (widget.db.update(widget.db.clientes)
                        ..where((tbl) => tbl.id.equals(widget.cliente!.id)))
                      .write(ClientesCompanion(nombre: Value(nombre)));
                } else {
                  // INSERTAR cliente nuevo
                  await widget.db
                      .into(widget.db.clientes)
                      .insert(ClientesCompanion.insert(nombre: nombre));
                }

                Navigator.pop(context);
              },
              child: Text(widget.cliente != null ? "Actualizar" : "Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
