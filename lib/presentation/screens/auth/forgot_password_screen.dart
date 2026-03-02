import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/auth/login_screen.dart';
import 'package:nexoappapp/presentation/screens/auth/otp_screen.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // Validación de correo
  bool _isEmailValid(String email) {
    if (email.contains(' ')) return false;
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  Future<void> _handleSendCode() async {
    final String email = emailController.text.trim();

    if (email.isEmpty || !_isEmailValid(email)) {
      _showMessage("Ingresa un correo válido sin espacios.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiConnect();
      await api.forgotPassword(email);

      // Si la API responde 200 (éxito), avanzamos
      _proceedToOtp(email);
    } catch (e) {
      // Si el error es 422 (falla de validación porque el correo no existe)
      if (e is DioException && e.response?.statusCode == 422) {
        _proceedToOtp(email); // Fingimos éxito y avanzamos igual
      } else {
        // Solo mostramos error si realmente se cayó el internet o el servidor
        _showMessage(
          "No se logró conectar al servidor. Comprueba tu conexión o inténtalo más tarde.",
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Nueva función para manejar la redirección limpia
  void _proceedToOtp(String email) {
    if (!mounted) return;

    _showMessage(
      "Si el correo está registrado, se enviará un código de verificación.",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Recuperar contraseña',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ingresa tu correo electrónico para enviarte un código de verificación.',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Campo de Email
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de Enviar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendCode,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Enviar código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
