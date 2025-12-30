import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cliente.dart';
import '../../../prestamos/presentation/pages/prestamos_cliente_page.dart';

/// Widget que muestra la información de un cliente en formato de tarjeta
class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClienteCard({
    super.key,
    required this.cliente,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y acciones
              Row(
                children: [
                  // Avatar con inicial
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    radius: 24,
                    child: Text(
                      _getInitials(cliente.nombre),
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${cliente.id ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Menú de acciones
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Información de contacto
              _buildInfoRow(
                icon: Icons.email,
                label: 'Email',
                value: cliente.email,
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Teléfono',
                value: cliente.telefono,
                color: Colors.green,
              ),
              
              // Fecha de registro si está disponible
              if (cliente.fechaRegistro != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Registrado',
                  value: _formatDate(cliente.fechaRegistro!),
                  color: Colors.orange,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Divider
              Divider(color: Colors.grey[300]),
              
              // Footer con acciones rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.phone,
                    label: 'Llamar',
                    onPressed: () => _handleCall(context),
                  ),
                  _buildActionButton(
                    icon: Icons.email,
                    label: 'Email',
                    onPressed: () => _handleEmail(context),
                  ),
                  _buildActionButton(
                    icon: Icons.account_balance_wallet,
                    label: 'Préstamos',
                    onPressed: () => _handlePrestamos(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una fila de información con icono
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye un botón de acción
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene las iniciales del nombre
  String _getInitials(String nombre) {
    final words = nombre.trim().split(' ');
    if (words.isEmpty) return 'C';
    
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Formatea la fecha de registro
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Maneja la acción de llamar
  void _handleCall(BuildContext context) {
    // TODO: Implementar funcionalidad de llamada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamar a ${cliente.telefono}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Maneja la acción de enviar email
  void _handleEmail(BuildContext context) {
    // TODO: Implementar funcionalidad de email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviar email a ${cliente.email}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Maneja la navegación a préstamos del cliente
  void _handlePrestamos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrestamosClientePage(
          clienteId: cliente.id!,
          clienteNombre: cliente.nombre,
        ),
      ),
    );
  }
}