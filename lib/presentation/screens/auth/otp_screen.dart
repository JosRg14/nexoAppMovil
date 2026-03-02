import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';
import 'package:nexoappapp/presentation/screens/auth/reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  // Variables de estado
  bool _isLoading = false;
  bool _isResendLoading = false;
  Timer? _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    _startCooldown(); // Inicia el contador al entrar
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpia el timer al cerrar la pantalla
    otpController.dispose();
    super.dispose();
  }

  // Lógica del contador
  void _startCooldown() {
    setState(() => _start = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  // Lógica para reenviar el código
  Future<void> _handleResendCode() async {
    setState(() => _isResendLoading = true);
    try {
      final api = ApiConnect();
      // Reutilizamos forgotPassword porque genera un nuevo token y marca el anterior como usado
      final success = await api.forgotPassword(widget.email);
      if (success) {
        _showSnackBar("Nuevo código enviado a su correo.");
        _startCooldown(); // Reinicia el contador
      }
    } catch (e) {
      _showSnackBar("Error al reenviar el código.");
    } finally {
      if (mounted) setState(() => _isResendLoading = false);
    }
  }

  // Lógica para verificar el código
  Future<void> _verifyOtp() async {
    final code = otpController.text;

    if (code.length < 6) {
      _showSnackBar("Ingresa el código de 6 dígitos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiConnect();
      final isValid = await api.verifyOtpCode(widget.email, code);

      if (isValid) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(email: widget.email, code: code),
          ),
        );
      }
    } catch (e) {
      String errorMsg = "No se logró conectar al servidor.";
      if (e is DioException && e.response?.statusCode == 400) {
        errorMsg = "Código inválido o expirado. Inténtalo de nuevo.";
      }
      _showSnackBar(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      /*appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              "Verificación",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Introduce el código enviado a:\n${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 60),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 20.0,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: "",
                hintText: "000000",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.1),
                  letterSpacing: 20.0,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 3),
                ),
              ),
              onChanged: (value) {
                if (value.length == 6) _verifyOtp();
              },
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("VERIFICAR CÓDIGO"),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN DE REENVÍO CON COOLDOWN
            _isResendLoading
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _start == 0 ? _handleResendCode : null,
                    child: Text(
                      _start == 0
                          ? "¿No recibiste el código? Reenviar"
                          : "Reenviar código en ${_start}s",
                      style: TextStyle(
                        color: _start == 0 ? Colors.blueAccent : Colors.grey,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
