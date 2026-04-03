import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';
import 'package:nexoappapp/presentation/screens/barber/service_evidence_screen.dart';

class ServiceInProgressScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const ServiceInProgressScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    // --- EXTRACCIÓN SEGURA DE DATOS ---
    final int idCita = appointment['id_cita'] ?? 0;

    final servicioMap = appointment['servicio'] ?? {};
    final String serviceName = servicioMap['nombre_servicio'] ?? 'Servicio';
    final String price = '\$${servicioMap['precio'] ?? '0.00'}';

    final clienteMap = appointment['cliente'] ?? {};
    final String clientName =
        '${clienteMap['nombre'] ?? 'Desconocido'} ${clienteMap['app_paterno'] ?? ''}'
            .trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'NEXOAPP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon/Animation
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orangeAccent, width: 2),
              ),
              child: const Icon(
                Icons.cut,
                size: 64,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 32),

            // Status Text
            Text(
              'En Proceso',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Detalles del Servicio
            Text(
              serviceName.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Cliente: $clientName",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const Spacer(),

            // Finish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      ),
                    ),
                  );

                  try {
                    final api = AppointmentsApi();

                    // Ahora 'response' es el Map que viene del return de la API
                    final response = await api.completarCita(idCita);

                    if (context.mounted)
                      Navigator.pop(context); // Quitar loader

                    // 1. Validamos usando la estructura real de tu JSON
                    if (response != null && response['success'] == true) {
                      // 2. Extraemos el registro_id desde data (según tu controlador)
                      final int registroId = response['data']['registro_id'];

                      if (!context.mounted) return;

                      // 3. Navegamos a la pantalla de evidencias pasando el ID real
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceEvidenceScreen(
                            appointment: appointment,
                            registroId: registroId,
                          ),
                        ),
                      );

                      if (result == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    } else {
                      // Manejo de errores si success es false o response es null
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Error al completar el servicio. Intenta de nuevo.",
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    debugPrint("Error en el botón finalizar: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'FINALIZAR SERVICIO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
