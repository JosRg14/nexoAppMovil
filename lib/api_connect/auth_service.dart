import 'package:dio/dio.dart';

// ... imports
class ApiConnect {
  final Dio _dio = Dio();
  final String _baseUrl =
      "https://hypersceptical-yu-skinflinty.ngrok-free.dev/api";

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
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.data is String &&
          response.data.contains('<!DOCTYPE html>')) {
        print("ERROR: Ngrok sigue bloqueando con HTML");
        return null;
      }

      if (response.statusCode == 200) {
        final apiData = response.data['data'];
        return {'token': apiData['token'], 'rol': apiData['rol']};
      }
    } on DioException catch (e) {
      print("Error en login: ${e.response?.data ?? e.message}");
    }
    return null;
  }
}
