import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexoappapp/presentation/screens/barber/appointments_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/super_user_dashboard_screen.dart';
import 'package:nexoappapp/presentation/screens/auth/login_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // 1. Instanciamos SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 2. Buscamos si existe el token y el rol
    final String? token = prefs.getString('token');
    final String? rol = prefs.getString('rol');

    // Pequeña pausa opcional para que no parpadee feo la pantalla
    await Future.delayed(const Duration(milliseconds: 500));

    // Si el widget ya no está en pantalla, cancelamos
    if (!mounted) return;

    // 3. Tomamos la decisión
    if (token != null && rol != null) {
      // Si hay sesión, lo mandamos a su pantalla según el rol
      switch (rol) {
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardScreen(),
            ), // Ajusta a tus nombres reales
          );
          break;
        case 'empleado':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
          );
          break;
        case 'superusuario':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuperUserDashboardScreen()),
          );
          break;
        default:
          // Si el rol es raro, lo mandamos al login por seguridad
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
      }
    } else {
      // Si NO hay token, lo mandamos a iniciar sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Esta es la pantalla que se ve mientras decide (un simple loading)
    return const Scaffold(
      backgroundColor: Colors.black, // O el color principal de tu app
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
