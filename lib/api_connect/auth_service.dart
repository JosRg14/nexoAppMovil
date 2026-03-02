import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Dio _dio = Dio();
final String _baseUrl =
    "https://hypersceptical-yu-skinflinty.ngrok-free.dev/api";

class ApiConnect {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'correo': email, 'contrasena': password},
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': '69420',
            'User-Agent': 'flutter-app',
            'Accept': 'application/json',
          },
          followRedirects: true,
          // Permitimos que pasen errores 401 para manejarlos como "Credenciales incorrectas"
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final apiData = response.data['data'];
        return {'token': apiData['token'], 'rol': apiData['rol']};
      }

      // Si llegamos aquí con un 401 o 404, devolvemos null (credenciales mal)
      return null;
    } on DioException catch (e) {
      // Si es un error de conexión (no hay internet, host no encontrado, timeout)
      print("Error de red detectado en Dio: ${e.message}");
      rethrow;
    } catch (e) {
      print("Error inesperado: $e");
      rethrow;
    }
  }

  Future<bool> registerEmpleado({
    required String nombre,
    required String appPaterno,
    required String appMaterno,
    required String correo,
    required String password,
    required double comision,
  }) async {
    // 1. Recuperamos el token que guardamos en el Login
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await _dio.post(
        '$_baseUrl/admin/register/empleado',
        data: {
          'nombre': nombre,
          'app_paterno': appPaterno,
          'app_materno': appMaterno,
          'correo': correo,
          'contrasena': password,
          'comision': comision,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      print("Error de permisos o datos: ${e.response?.data}");
      return false;
    }
  }

  Future<void> clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('rol');
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token != null) {
        await _dio.post(
          '$_baseUrl/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (e) {
      debugPrint("Error en logout de API (posiblemente token ya expirado): $e");
    } finally {
      // 2. PASE LO QUE PASE con la API, borramos lo local
      // Así el usuario no se queda trabado si no hay internet
      await clearLocalSession();
    }
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/password/forgot',
        data: {'email': email},
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': '69420',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOtpCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/password/verify-code',
        data: {'email': email, 'code': code},
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': '69420',
            'Accept': 'application/json',
          },
        ),
      );

      // Si el código es válido, Laravel responde 200
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Si Laravel responde 400 (Código inválido/expirado), Dio lanzará excepción
      debugPrint("Error en validación de OTP: ${e.response?.data['message']}");
      rethrow;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/password/reset',
        data: {
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': password,
        },
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': '69420',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Error en resetPassword: ${e.response?.data['message']}");
      rethrow;
    }
  }
}
