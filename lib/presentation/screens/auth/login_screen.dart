import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/barber/appointments_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/super_user_dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [
              // 1. Header Area (30% height) - Option B from Design System
              Container(
                height: size.height * 0.30,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black, // Placeholder for image
                  // TODO: Add background image here
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Color(0xFF1A1A1A)],
                  ),
                ),
                child: Center(
                  child: Text(
                    'NEXOAPP',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),

              // 2. Form Area (70% height)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Back', // From wireframe
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Iniciar sesión',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rellena los siguientes requisitos',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      TextField(
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText:
                              'Contraseña', // Adjusted spelling for Spanish keyboard support if needed, or 'Contrasena' as in wireframe
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardScreen(),
                              ),
                            );
                          },
                          child: const Text('Iniciar Sesion'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Shortcut to Appointments (Temporary or Role-based)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppointmentsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Ver Mis Citas (Barbero)',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Shortcut to Super User Dashboard (Temporary)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SuperUserDashboardScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Super Usuario',
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
