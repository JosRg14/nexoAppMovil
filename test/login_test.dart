import 'package:flutter_test/flutter_test.dart';

// 1. Aquí simulamos la función que usarías en tu app para validar el correo
bool esCorreoValido(String correo) {
  if (correo.isEmpty) return false;
  if (!correo.contains('@')) return false;
  return true;
}

void main() {
  // 2. Agrupamos las pruebas relacionadas al Login
  group('Pruebas de Validación de Login', () {
    
    test('Debe devolver TRUE si el correo es válido', () {
      // Usamos un correo de prueba para NexoApp
      bool resultado = esCorreoValido('cliente@nexoapp.com');
      
      // expect(lo_que_obtuviste, lo_que_esperabas)
      expect(resultado, true); 
    });

    test('Debe devolver FALSE si el correo no tiene @', () {
      bool resultado = esCorreoValido('clientenexoapp.com');
      expect(resultado, false);
    });

    test('Debe devolver FALSE si el campo está vacío', () {
      bool resultado = esCorreoValido('');
      expect(resultado, false);
    });

  });
}