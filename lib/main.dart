import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'screens/dashboard/resumen_page.dart';

void main() {
  runApp(const PrestamosApp());
}

class PrestamosApp extends StatelessWidget {
  const PrestamosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase();

    return MaterialApp(
      title: "Prestamos Corral",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 2, 137, 248),
      ),
      home: ResumenPage(db: db),
    );
  }
}
