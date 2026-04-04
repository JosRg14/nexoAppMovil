import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

final Dio _dio = Dio();
final String _baseUrl = "https://devlink-servidorapi.td60xq.easypanel.host";
/*"https://hypersceptical-yu-skinflinty.ngrok-free.dev/api";*/

class ApiConnect {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/login',
        data: {'correo': email, 'contrasena': password},
        options: Options(
          headers: {'User-Agent': 'flutter-app', 'Accept': 'application/json'},
          followRedirects: true,
          // Permitimos que pasen errores 401 para manejarlos como "Credenciales incorrectas"
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final apiData = response.data['data'];
        final usuario = apiData['usuario'];
        final rol = apiData['rol'];

        // Extraemos los objetos anidados de forma segura
        final negocio = usuario['negocio'];
        final empleado = usuario['empleado'];

        return {
          'token': apiData['token'],
          'rol': rol,
          'id_negocio': negocio != null ? negocio['id_negocio'] : null,
          // id_empleado solo vendrá si el rol es 'empleado'
          'id_empleado': empleado != null ? empleado['id_empleado'] : null,
        };
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Error de red detectado en Dio: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error inesperado: $e");
      rethrow;
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
          '$_baseUrl/api/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (e) {
      debugPrint("Error en logout de API (posiblemente token ya expirado): $e");
    } finally {
      await clearLocalSession();
    }
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/password/forgot',
        data: {'email': email},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Error en: $e");
      rethrow;
    }
  }

  Future<bool> verifyOtpCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/password/verify-code',
        data: {'email': email, 'code': code},
        options: Options(headers: {'Accept': 'application/json'}),
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
        '$_baseUrl/api/password/reset',
        data: {
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': password,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Error en resetPassword: ${e.response?.data['message']}");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loginWithGoogle(String rol) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Descomenta y pega tu ID si usas el que creaste manualmente en Google Cloud.
        // Si usas el google-services.json de Firebase, puedes borrar esta línea.
        // serverClientId: 'TU_ID_DE_CLIENTE_WEB.apps.googleusercontent.com',
      );

      // 1. Iniciar sesión en el dispositivo
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("El usuario canceló el login de Google");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Preparar los datos EXACTAMENTE como los pide Laravel
      final Map<String, dynamic> data = {
        'google_token': googleAuth.accessToken,
        'rol': rol,
      };

      debugPrint("Enviando token a Laravel...");

      // 4. Enviar a tu backend usando Dio
      final response = await _dio.post(
        '$_baseUrl/api/auth/google/mobile',
        data: data,
        options: Options(
          headers: {'Accept': 'application/json'},
          // Permitir códigos 400 o 403 para manejarlos manualmente
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final apiData = response.data['data'];
        // En este endpoint, 'negocio' está al mismo nivel que 'usuario'
        final negocio = apiData['negocio'];

        debugPrint('-----Negocio ID: ${negocio['id_negocio']}');

        // Retornamos el id_negocio para que la UI lo guarde
        return {
          'token': apiData['token'],
          'rol': apiData['usuario']['rol'],
          'id_negocio': negocio != null ? negocio['id_negocio'] : null,
          'necesita_completar_registro':
              apiData['necesita_completar_registro'] ?? false,
        };
      } else {
        // Lanzamos una excepción con el mensaje EXACTO que manda Laravel (Ej: Error 403)
        final errorMessage =
            response.data['message'] ?? 'Error desconocido del servidor';
        debugPrint("Error del servidor: $errorMessage");
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint("Error de red al conectar con Laravel: ${e.message}");
      throw Exception(
        "No se pudo conectar con el servidor. Revisa tu conexión.",
      );
    } catch (e) {
      debugPrint("Error interno en Google Sign-In: $e");
      rethrow;
    }
  }
}
