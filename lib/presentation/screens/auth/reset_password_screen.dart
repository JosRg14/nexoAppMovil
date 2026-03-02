import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/auth/login_screen.dart';
//import 'package:nexoappapp/presentation/screens/auth/otp_screen.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _handleReset() async {
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;

    // 1. Validaciones locales
    if (pass.length < 6) {
      _showError("La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    if (pass != confirm) {
      _showError("Las contraseñas no coinciden.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiConnect();

      // 2. Llamada real a la API
      final success = await api.resetPassword(
        email: widget.email,
        code: widget.code,
        password: pass,
      );

      if (success) {
        if (!mounted) return;
        // 3. Mostrar diálogo de éxito (este ya lo tienes y redirige al Login)
        _showSuccessDialog();
      }
    } catch (e) {
      // Manejo de errores profesional
      String errorMsg = "No se logró conectar al servidor.";

      if (e is DioException && e.response?.statusCode == 400) {
        errorMsg = e.response?.data['message'] ?? "El código ya no es válido.";
      }

      _showError(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text(
          "¡Contraseña actualizada!\nAhora puedes iniciar sesión con tu nueva clave.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Limpiamos el stack y volvemos al login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text(
              "IR AL LOGIN",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      /*appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OtpScreen()),
            );
          },
        ),
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const SizedBox(height: 20),
            const Text(
              "Nueva contraseña",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Crea una contraseña segura que no uses en otros sitios.",
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Nueva Contraseña
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirmar Contraseña
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirm,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                prefixIcon: const Icon(Icons.lock_reset, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleReset,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("ACTUALIZAR CONTRASEÑA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
