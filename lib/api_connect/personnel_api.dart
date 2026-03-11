import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

final Dio _dio = Dio();
final String _baseUrl = "https://devlink-servidorapi.td60xq.easypanel.host/api";

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

  Future<bool> registerEmpleado({
    required String nombre,
    required String appPaterno,
    required String appMaterno,
    required String correo,
    required String password,
    required double comision,
    required String estado,
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
          'estado': estado,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      print("Error de permisos o datos: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> updateEmpleado({
    required String id,
    required String nombre,
    required String appPaterno,
    required String appMaterno,
    required String correo,
    required double comision,
    required String estado,
    String? password, // Opcional al editar
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      // Preparamos el mapa de datos básicos
      final Map<String, dynamic> data = {
        'nombre': nombre,
        'app_paterno': appPaterno,
        'app_materno': appMaterno,
        'correo': correo,
        'comision': comision,
        'estado': estado,
      };

      // Si el usuario escribió algo en el campo de contraseña, lo agregamos
      if (password != null && password.isNotEmpty) {
        data['contrasena'] = password;
      }

      final response = await _dio.put(
        '$_baseUrl/empleados/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      // Laravel suele retornar 200 OK para updates exitosos
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      print("Error al actualizar empleado: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("Error inesperado: $e");
      return false;
    }
  }
}
