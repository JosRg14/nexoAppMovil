import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';

class ServiceEvidenceScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final int
  registroId; // Añadido: Recibe el ID del registro generado en Laravel

  const ServiceEvidenceScreen({
    super.key,
    required this.appointment,
    required this.registroId, // Lo volvemos requerido
  });

  @override
  State<ServiceEvidenceScreen> createState() => _ServiceEvidenceScreenState();
}

class _ServiceEvidenceScreenState extends State<ServiceEvidenceScreen> {
  final _notesController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error al capturar imagen: $e");
    }
  }

  Future<void> _enviarDatos(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      ),
    );

    final api = AppointmentsApi();

    // Llamamos a la API usando el registroId de la pantalla anterior
    final success = await api.subirEvidencias(
      registroId: widget.registroId,
      notas: _notesController.text,
      imagen: _imageFile,
    );

    if (context.mounted) Navigator.pop(context); // Quitar loader

    if (success) {
      if (context.mounted) Navigator.pop(context, true); // Regresar a la lista
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al guardar la evidencia"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicioMap = widget.appointment['servicio'] ?? {};
    final String serviceName = servicioMap['nombre_servicio'] ?? 'Servicio';

    final clienteMap = widget.appointment['cliente'] ?? {};
    final String clientName =
        '${clienteMap['nombre'] ?? 'Cliente'} ${clienteMap['app_paterno'] ?? ''}'
            .trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'EVIDENCIA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen del Servicio
            Text(
              serviceName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cliente: $clientName',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Photo Placeholder
            const Text(
              'FOTO DEL RESULTADO',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 56,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Toca para tomar foto',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Notes
            const Text(
              'NOTAS DEL SERVICIO',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                hintText: 'Ej. El cliente pidió un desvanecido bajo...',
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[900]!),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón Principal: Confirmar con Datos
            ElevatedButton(
              onPressed: () =>
                  _enviarDatos(context), // Ya llama al método correcto
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'GUARDAR Y CERRAR CITA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Botón Secundario: Continuar sin Evidencia
            TextButton(
              onPressed: () {
                // Simplemente regresamos true para indicar que todo terminó
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.grey[400],
              ),
              child: const Text(
                'FINALIZAR SIN EVIDENCIA',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
