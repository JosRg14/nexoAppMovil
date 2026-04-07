import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

final Dio _dio = Dio();
final String _baseUrl = "https://devlink-servidorapi.td60xq.easypanel.host/api";

class PersonnelApi {
  Future<List<dynamic>> getEmpleados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final int? negocioId = prefs.getInt('id_negocio');

      if (negocioId == null) {
        return [];
      }

      final response = await _dio.get(
        '$_baseUrl/mis-empleados',
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
      debugPrint("Error al obtener empleados: $e");
      return [];
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
    //Recuperamos el token que guardamos en el Login
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
