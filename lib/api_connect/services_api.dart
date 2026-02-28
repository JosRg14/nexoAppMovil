import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesApi {
  final String _baseUrl =
      'https://hypersceptical-yu-skinflinty.ngrok-free.dev/api';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> createService({
    required String nombre,
    required String descripcion,
    required String precio,
    required String duracion,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      // 1. Creamos el FormData (el contenedor para multipart)
      FormData formData = FormData.fromMap({
        'nombre_servicio': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'duracion_estimada': duracion,
      });

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'imagen',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      // 3. Enviamos la petición
      final response = await _dio.post(
        '$_baseUrl/servicios',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Servicio creado exitosamente',
      };
    } on DioException catch (e) {
      // Manejo de errores de validación (422)
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        return {
          'success': false,
          'message': errors.values.first.first.toString(),
        };
      }
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Error de servidor',
      };
    }
  }

  Future<List<dynamic>> getServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await _dio.get(
        '$_baseUrl/servicios',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
