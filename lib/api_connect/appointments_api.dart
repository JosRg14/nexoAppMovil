import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class AppointmentsApi {
  final String _baseUrl = "https://devlink-servidorapi.td60xq.easypanel.host";
  final Dio _dio = Dio();

  // Método privado para evitar repetir la obtención del token y los headers
  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    return Options(
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<List<dynamic>> getAppointmentsByDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? idEmpleado = prefs.getInt('id_empleado');

      // Formatear la fecha a YYYY-MM-DD
      final String dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Preparamos los parámetros de búsqueda
      final Map<String, dynamic> queryParams = {'fecha': dateString};

      // SI ES EMPLEADO: Agregamos el filtro.
      // SI ES ADMIN: idEmpleado será null en SharedPreferences.
      if (idEmpleado != null) {
        queryParams['empleado'] = idEmpleado;
      }

      final response = await _dio.get(
        '$_baseUrl/api/citas',
        queryParameters: queryParams,
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 200) {
        // Laravel devuelve un array plano [], así que lo retornamos directo
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      debugPrint(
        "Error de red al obtener citas: ${e.response?.data ?? e.message}",
      );
      return [];
    } catch (e) {
      debugPrint("Error inesperado al obtener citas: $e");
      return [];
    }
  }

  Future<bool> iniciarCita(int idCita) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/api/citas/$idCita/iniciar',
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 200) {
        debugPrint("Servicio iniciado correctamente en la API");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("Error al iniciar cita: ${e.response?.data ?? e.message}");
      return false;
    }
  }

  Future<Map<String, dynamic>?> completarCita(int idCita) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/api/citas/$idCita/completar',
        options: await _getAuthOptions(),
      );

      // Verificamos el status 200 que envía tu controlador de Laravel
      if (response.statusCode == 200) {
        debugPrint("Cita completada correctamente en la API");
        // Retornamos el mapa completo: { "success": true, "data": { ... } }
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Error al completar cita: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      debugPrint("Error inesperado: $e");
      return null;
    }
  }

  Future<bool> subirEvidencias({
    required int registroId,
    required String? notas,
    File? imagen,
  }) async {
    try {
      Map<String, dynamic> data = {};

      // Solo agregamos notas si realmente hay texto, para evitar mandar "null" como String
      if (notas != null && notas.trim().isNotEmpty) {
        data["notas"] = notas;
      }

      if (imagen != null) {
        // Tu API espera un array 'fotos', así que usamos fotos[]
        data["fotos[]"] = await MultipartFile.fromFile(
          imagen.path,
          filename: imagen.path.split('/').last,
          contentType: MediaType("image", "jpeg"),
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        '$_baseUrl/api/registros/$registroId/evidencias',
        data: formData,
        options: await _getAuthOptions(),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(
        "Error de red en subirEvidencias: ${e.response?.data ?? e.message}",
      );
      return false;
    } catch (e) {
      debugPrint("Error en subirEvidencias: $e");
      return false;
    }
  }

  // 1. Para cancelar con un motivo (Otro)
  Future<bool> cancelarCita(int idCita, String motivo) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/api/citas/$idCita/cancelar',
        options: await _getAuthOptions(),
        data: {'motivo': motivo},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al cancelar cita: $e');
      return false;
    }
  }

  // 2. Para marcar como inasistencia
  Future<bool> marcarNoAsistio(int idCita) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/api/citas/$idCita/no-asistio',
        options: await _getAuthOptions(),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al marcar no asistencia: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getEmployeeReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? idEmpleado = prefs.getInt('id_empleado');

      if (idEmpleado == null) return {};

      final response = await _dio.get(
        '$_baseUrl/api/empleados/$idEmpleado/valoracion',
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 200) {
        // Retornamos directamente el objeto 'data' del JSON de Laravel
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      debugPrint(
        "Error al obtener valoraciones: ${e.response?.data ?? e.message}",
      );
      return {};
    } catch (e) {
      debugPrint("Error inesperado en valoraciones: $e");
      return {};
    }
  }

  // Obtener empleados del negocio
  Future<List<Map<String, dynamic>>> getActiveEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? negocioId = prefs.getInt('id_negocio');

      if (negocioId == null) return [];
      final response = await _dio.get(
        '$_baseUrl/api/empleados',
        queryParameters: {'negocio_id': negocioId, 'estado': 'activo'},
        options: await _getAuthOptions(),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint("Error obteniendo empleados: $e");
      return [];
    }
  }

  // Verificar si un empleado tiene un slot libre a una hora específica
  Future<bool> checkEmployeeAvailability(
    int empleadoId,
    String fecha,
    String horaRequerida,
    int duracion,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/disponibilidad/empleado/$empleadoId',
        queryParameters: {'fecha': fecha, 'duracion': duracion},
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> slots = response.data['slots'] ?? [];
        // Comparamos si la hora requerida coincide con el inicio de algún slot disponible
        // Nota: Asegúrate de que los formatos de hora coincidan (ej. "14:30" vs "14:30:00")
        return slots.any(
          (slot) => slot['hora_inicio'].toString().startsWith(horaRequerida),
        );
      }
      return false;
    } catch (e) {
      debugPrint(
        "Error verificando disponibilidad del empleado $empleadoId: $e",
      );
      return false;
    }
  }

  // Actualizar datos de una cita (incluyendo el cambio de empleado)
  Future<Map<String, dynamic>> updateAppointment(
    int idCita,
    Map<String, dynamic> data,
  ) async {
    try {
      // Usamos patch o put según lo tengas definido en tus rutas de Laravel
      final response = await _dio.put(
        '$_baseUrl/api/citas/$idCita',
        data: data,
        options: await _getAuthOptions(),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Cita actualizada exitosamente',
      };
    } on DioException catch (e) {
      // Aquí atrapamos los errores 400, 409, etc. que manda tu controlador
      if (e.response != null && e.response?.data != null) {
        debugPrint("Error al actualizar cita: ${e.response?.data}");
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Error al actualizar la cita',
        };
      }
      debugPrint("Error al actualizar cita: ${e.response?.data}");
      return {'success': false, 'message': 'Error de conexión con el servidor'};
    } catch (e) {
      debugPrint('Error al actualizar cita: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }
}
