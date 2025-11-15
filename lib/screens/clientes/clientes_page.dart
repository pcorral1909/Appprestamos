import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import 'agregar_cliente_page.dart';
import '../prestamos/prestamos_cliente_page.dart';

class ClientesPage extends StatefulWidget {
  final AppDatabase db;

  const ClientesPage({super.key, required this.db});

  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  late Stream<List<Cliente>> clientesStream;

  @override
  void initState() {
    super.initState();
    clientesStream = widget.db.select(widget.db.clientes).watch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clientes")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgregarClientePage(db: widget.db),
            ),
          );
          setState(() {}); // refresca lista después de agregar
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: clientesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clientes = snapshot.data!;

          if (clientes.isEmpty) {
            return const Center(child: Text("No hay clientes aún"));
          }

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (_, i) {
              final c = clientes[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(c.nombre)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AgregarClientePage(
                                    db: widget.db,
                                    cliente: c,
                                  ),
                                ),
                              );
                              setState(
                                () {},
                              ); // refresca lista después de editar
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Confirmar"),
                                  content: const Text(
                                    "¿Deseas eliminar este cliente y todos sus préstamos?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Eliminar"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                // BORRADO EN CASCADA: primero préstamos
                                await (widget.db.delete(widget.db.prestamos)
                                      ..where(
                                        (tbl) => tbl.clienteId.equals(c.id),
                                      ))
                                    .go();

                                // Luego borrar el cliente
                                await (widget.db.delete(
                                  widget.db.clientes,
                                )..where((tbl) => tbl.id.equals(c.id))).go();

                                setState(() {}); // refresca lista
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PrestamosClientePage(db: widget.db, cliente: c),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
