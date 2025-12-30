import 'package:flutter/material.dart';
import '../core/di/injection_container.dart';
import '../features/clientes/domain/usecases/delete_cliente_usecase.dart';
import '../features/prestamos/domain/usecases/delete_prestamo_usecase.dart';

class DeleteUtils {
  /// Muestra un diálogo de confirmación para eliminar un cliente
  static Future<bool> showDeleteClienteDialog(BuildContext context, String nombreCliente) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de que deseas eliminar al cliente "$nombreCliente"?\\n\\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Muestra un diálogo de confirmación para eliminar un préstamo
  static Future<bool> showDeletePrestamoDialog(BuildContext context, int prestamoId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Préstamo'),
        content: Text('¿Estás seguro de que deseas eliminar el préstamo #$prestamoId?\\n\\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Elimina un cliente y muestra el resultado
  static Future<void> deleteCliente(BuildContext context, int clienteId, String nombreCliente) async {
    final confirmed = await showDeleteClienteDialog(context, nombreCliente);
    if (!confirmed) return;

    try {
      final useCase = sl<DeleteClienteUseCase>();
      final result = await useCase(DeleteClienteParams(clienteId: clienteId));

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar cliente: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cliente "$nombreCliente" eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Elimina un préstamo y muestra el resultado
  static Future<void> deletePrestamo(BuildContext context, int prestamoId) async {
    final confirmed = await showDeletePrestamoDialog(context, prestamoId);
    if (!confirmed) return;

    try {
      final useCase = sl<DeletePrestamoUseCase>();
      final result = await useCase(DeletePrestamoParams(prestamoId: prestamoId));

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar préstamo: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Préstamo #$prestamoId eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}