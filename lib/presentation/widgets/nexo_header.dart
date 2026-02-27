import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/auth_service.dart'; // Ajusta a tu nombre de archivo
import 'package:nexoappapp/presentation/screens/auth/login_screen.dart';

class NexoHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NexoHeader({super.key, this.title = 'NEXOAPP'});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // Usamos un context diferente para el diálogo
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Deseas salir de tu cuenta?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              // 1. Cerramos el diálogo usando su propio context
              Navigator.pop(dialogContext);

              // 2. Ejecutamos limpieza
              final api = ApiConnect();
              await api.logout();

              // 3. Navegamos usando el context de la PANTALLA (el del Stateless)
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'SALIR',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
    );
  }
}
