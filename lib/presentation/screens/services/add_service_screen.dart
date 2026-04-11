import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexoappapp/api_connect/services_api.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  // --- NUEVOS CONTROLADORES Y VARIABLES DE COMISIÓN ---
  final _commissionController = TextEditingController();
  String _selectedCommissionType = 'Sin comisión';

  File? _image;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios para actualizar el label dinámico
    _priceController.addListener(_updateUI);
    _commissionController.addListener(_updateUI);
  }

  @override
  void dispose() {
    _priceController.removeListener(_updateUI);
    _commissionController.removeListener(_updateUI);
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  void _updateUI() => setState(() {});

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

  // --- FUNCIÓN PARA CALCULAR LA GANANCIA DINÁMICA ---
  String _getCalculatedCommission() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final commission = double.tryParse(_commissionController.text) ?? 0.0;
    double result = 0.0;

    if (_selectedCommissionType == 'Porcentaje(%)') {
      result = (price * commission) / 100;
    } else if (_selectedCommissionType == 'Monto Fijo(\$)') {
      result = commission;
    }

    return result.toStringAsFixed(2);
  }

  Future<void> _submitService() async {
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

    // --- PREPARAR DATOS DE COMISIÓN PARA LA API ---
    String? tipoComision;
    String? comisionPorcentaje;
    String? comisionFija;

    if (_selectedCommissionType == 'Porcentaje(%)') {
      tipoComision = 'porcentaje';
      comisionPorcentaje = _commissionController.text;
    } else if (_selectedCommissionType == 'Monto Fijo(\$)') {
      tipoComision = 'fija';
      comisionFija = _commissionController.text;
    }

    final api = ServicesApi();
    final result = await api.createService(
      nombre: _nameController.text,
      descripcion: _descController.text,
      precio: _priceController.text,
      duracion: _durationController.text,
      tipoComision: tipoComision,
      comisionPorcentaje: comisionPorcentaje,
      comisionFija: comisionFija,
      imageFile: _image,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
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

            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre del servicio',
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),

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

            // --- NUEVA SECCIÓN DE COMISIÓN ---
            DropdownButtonFormField<String>(
              value: _selectedCommissionType,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Tipo de comisión'),
              items: ['Sin comisión', 'Porcentaje(%)', 'Monto Fijo(\$)']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCommissionType = val!;
                  _commissionController.clear();
                });
              },
            ),
            const SizedBox(height: 24),

            if (_selectedCommissionType != 'Sin comisión') ...[
              TextField(
                controller: _commissionController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _selectedCommissionType == 'Porcentaje(%)'
                      ? 'Porcentaje (%)'
                      : 'Monto Fijo (\$)',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'El empleado ganará: \$${_getCalculatedCommission()}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
            ],

            // --- FIN DE SECCIÓN DE COMISIÓN ---
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
                onPressed: _isLoading ? null : _submitService,
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
