import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexoappapp/api_connect/services_api.dart';

class AddServiceScreen extends StatefulWidget {
  // Cambiado a StatefulWidget
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  // 1. Controladores para capturar el texto
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  // 2. Variable para guardar la imagen seleccionada
  File? _image;
  final _picker = ImagePicker();

  bool _isLoading = false;

  // 3. Función para seleccionar imagen
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitService() async {
    // Validaciones básicas en el móvil antes de enviar
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa los campos obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final api = ServicesApi();
    final result = await api.createService(
      nombre: _nameController.text,
      descripcion: _descController.text,
      precio: _priceController.text,
      duracion: _durationController.text,
      imageFile: _image,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Mostrar el mensaje de éxito que viene de Laravel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Retornamos 'true' para indicar que se actualice la lista anterior
    } else {
      // Mostrar el mensaje de error de validación de Laravel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Agregar servicios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete los campos para registrar el Servicio',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // NOMBRE
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre del servicio',
              ),
            ),
            const SizedBox(height: 24),

            // DESCRIPCIÓN
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),

            // PRECIO Y DURACIÓN
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Precio',
                hintText: '\$0.00',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Duración (Minutos)',
              ),
            ),
            const SizedBox(height: 32),

            // SECCIÓN DE IMAGEN
            Text(
              'Imagen del servicio (opcional)',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: _image != null
                    ? ClipRRect(
                        // Si hay imagen, la mostramos
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.add_a_photo,
                        color: Colors.grey,
                        size: 40,
                      ),
              ),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _submitService, // Deshabilita si está cargando
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Agregar Servicio',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
