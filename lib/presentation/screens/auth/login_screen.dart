import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';
import 'package:nexoappapp/presentation/screens/barber/appointments_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:nexoappapp/presentation/screens/dashboard/super_user_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexoappapp/presentation/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // 1. Header Area
                  Container(
                    height: size.height * 0.20,
                    width: double.infinity,
                    decoration: const BoxDecoration(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 40),

                        // Email Field
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(
                              Icons.password,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Iniciar Sesión'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Google Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _handleGoogleLogin,
                            icon: Image.network(
                              'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                              height: 24,
                            ),
                            label: const Text(
                              'Continuar con Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white.withOpacity(
                                0.05,
                              ), // Efecto cristal sutil
                            ),
                          ),
                        ),
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

  // --- MÉTODOS DE LÓGICA ---

  Future<void> _handleLogin() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    // Validaciones locales básicas
    if (email.isEmpty || password.isEmpty) {
      _showError("Por favor, completa todos los campos.");
      return;
    }

    if (!_isEmailValid(email)) {
      _showError("El formato del correo no es válido.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiConnect();
      // Intentamos el login
      final userData = await api.login(email, password);

      if (userData != null) {
        // ÉXITO: Instancia de SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // 1. Guardar Token y Rol (Datos base)
        await prefs.setString('token', userData['token'] ?? '');
        await prefs.setString('rol', userData['rol'] ?? '');

        // 2. Guardar id_negocio (Si viene en el mapa)
        if (userData['id_negocio'] != null) {
          await prefs.setInt('id_negocio', userData['id_negocio']);
        } else {
          await prefs.remove('id_negocio');
        }

        debugPrint('-----Negocio ID: ${prefs.getInt('id_negocio')}');

        // 3. Guardar id_empleado (Solo si el rol es empleado)
        if (userData['id_empleado'] != null) {
          await prefs.setInt('id_empleado', userData['id_empleado']);
        } else {
          // Si no es empleado, nos aseguramos de borrar cualquier ID anterior
          await prefs.remove('id_empleado');
        }

        if (!mounted) return;

        // Navegación final
        _navigateBasedOnRol(userData['rol']);
      } else {
        _showError("Correo o contraseña incorrectos. Inténtalo de nuevo.");
      }
    } catch (e) {
      _showError(
        "No se logró conectar al servidor. Comprueba tu conexión o inténtalo más tarde.",
      );
      debugPrint("Error atrapado en la UI: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateBasedOnRol(String rol) {
    switch (rol) {
      case 'admin':
        _navigate(const DashboardScreen());
        break;
      case 'empleado':
        _navigate(const AppointmentsScreen());
        break;
      case 'superusuario':
        _navigate(const SuperUserDashboardScreen());
        break;
      default:
        _showError("Rol no reconocido: $rol");
    }
  }

  // Método auxiliar para navegar
  void _navigate(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  bool _isEmailValid(String email) {
    if (email.contains(' ')) return false;
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final api = ApiConnect();
      final userData = await api.loginWithGoogle('admin');

      if (userData != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', userData['token']);
        await prefs.setString('rol', userData['rol']);

        if (userData['id_negocio'] != null) {
          await prefs.setInt('id_negocio', userData['id_negocio']);
        } else {
          await prefs.remove('id_negocio');
        }

        if (!mounted) return;
        _navigateBasedOnRol(userData['rol']);
      }
    } catch (e) {
      debugPrint("Error atrapado en UI: $e");
      final cleanMessage = e.toString().replaceAll('Exception: ', '');

      _showError(cleanMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
