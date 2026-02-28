import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

final Dio _dio = Dio();
final String _baseUrl =
    "https://hypersceptical-yu-skinflinty.ngrok-free.dev/api";

class PersonnelApi {
  Future<List<dynamic>> getEmpleados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await _dio.get(
        '$_baseUrl/empleados', // Tu ruta GET
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data']; // Retorna el array de empleados
      }
      return [];
    } catch (e) {
      print("Error al obtener empleados: $e");
      return []; // En caso de error, retornamos lista vacía
    }
  }
}
