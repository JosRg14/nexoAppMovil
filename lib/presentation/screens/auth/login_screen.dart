import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';
import 'package:nexoappapp/presentation/screens/barber/appointments_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/super_user_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // SafeArea evita que el notch de la cámara tape el contenido
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            // Esto asegura que ocupe toda la pantalla pero le permite crecer más si es necesario
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
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
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                      ),
                    ),
                  ),

                  // 2. Form Area
                  // Aquí quitamos el "Expanded" y lo reemplazamos por un contenedor normal.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Email Field
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password Field
                        TextField(
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // 1. Llamamos a tu nuevo servicio
                              final api = ApiConnect();

                              final userData = await api.login(
                                emailController.text,
                                passwordController.text,
                              );

                              // 2. Verificamos si el login fue exitoso
                              if (userData != null) {
                                //Guardado ddel Token con SharedPreferences
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'token',
                                  userData['token'],
                                );
                                await prefs.setString('rol', userData['rol']);

                                final String rol =
                                    userData['rol']; // Sacamos el rol de la respuesta

                                // 3. El Switch para redirigir según el rol
                                switch (rol) {
                                  case 'admin':
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardScreen(),
                                      ),
                                    );
                                    break;
                                  case 'empleado':
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AppointmentsScreen(),
                                      ),
                                    );
                                    break;
                                  case 'superusuario':
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SuperUserDashboardScreen(),
                                      ),
                                    );
                                    break;
                                  default:
                                    // Por si la API devuelve un rol raro
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Rol no reconocido"),
                                      ),
                                    );
                                }
                              } else {
                                // Si userData es null, falló el correo o la contraseña
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Credenciales incorrectas"),
                                  ),
                                );
                              }
                            },
                            child: const Text('Iniciar Sesion'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
