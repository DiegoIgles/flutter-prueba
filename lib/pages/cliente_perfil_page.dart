import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/auth_service.dart';

class ClientePerfilPage extends StatefulWidget {
  final Cliente? cliente;

  const ClientePerfilPage({super.key, this.cliente});

  @override
  State<ClientePerfilPage> createState() => _ClientePerfilPageState();
}

class _ClientePerfilPageState extends State<ClientePerfilPage> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    final confirmar = await _mostrarDialogoConfirmacion();
    if (confirmar == true) {
      await _authService.logout(chofer: false);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<bool?> _mostrarDialogoConfirmacion() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta de perfil principal
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF197B9C), Color(0xFF0B0530)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nombre completo
                    Text(
                      widget.cliente != null
                          ? '${widget.cliente!.nombre} ${widget.cliente!.apellido}'
                          : 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Text(
                      widget.cliente?.email ?? 'No disponible',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Información personal
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.cliente != null) ...[
                      _buildInfoRow(
                        'Nombre',
                        widget.cliente!.nombre,
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Apellido',
                        widget.cliente!.apellido,
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Correo electrónico',
                        widget.cliente!.email,
                        Icons.email_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Teléfono',
                        widget.cliente!.telefono ?? 'No especificado',
                        Icons.phone_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'ID de Cliente',
                        '#${widget.cliente!.id.toString().padLeft(6, '0')}',
                        Icons.badge_outlined,
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          'Información no disponible',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Opciones de cuenta
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Configuración de cuenta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildOptionTile(
                    icon: Icons.edit_outlined,
                    title: 'Editar perfil',
                    subtitle: 'Actualizar información personal',
                    onTap: () {
                      // TODO: Implementar edición de perfil
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Funcionalidad próximamente disponible'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.lock_outline,
                    title: 'Cambiar contraseña',
                    subtitle: 'Actualizar tu contraseña de acceso',
                    onTap: () {
                      // TODO: Implementar cambio de contraseña
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Funcionalidad próximamente disponible'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Configurar preferencias de notificación',
                    onTap: () {
                      // TODO: Implementar configuración de notificaciones
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Funcionalidad próximamente disponible'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.help_outline,
                    title: 'Ayuda y soporte',
                    subtitle: 'Obtener ayuda o contactar soporte',
                    onTap: () {
                      // TODO: Implementar ayuda y soporte
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Funcionalidad próximamente disponible'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón de cerrar sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Información de la aplicación
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Aplicación de Transporte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF197B9C),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF197B9C),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
