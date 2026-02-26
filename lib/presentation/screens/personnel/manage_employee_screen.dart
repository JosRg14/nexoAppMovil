import 'package:flutter/material.dart';

class ManageEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic>?
  employee; // If null, we are creating. If exists, we are editing.

  const ManageEmployeeScreen({super.key, this.employee});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  // Controllers
  final _nombreController = TextEditingController();
  final _paternoController = TextEditingController();
  final _maternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _commissionController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      // Pre-fill data if editing
      _nombreController.text = widget.employee!['name'] ?? '';
      _paternoController.text = widget.employee!['apellido_paterno'] ?? '';
      _maternoController.text = widget.employee!['apellido_materno'] ?? '';
      _correoController.text = widget.employee!['correo'] ?? '';
      _passwordController.text = ''; // Contraseña en blanco por defecto
      _commissionController.text =
          widget.employee!['comision']?.toString() ?? '50';
      _isActive = widget.employee!['status'] == 'Activo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Empleado' : 'Nuevo Empleado',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                // TODO: Delete Logic
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Placeholder
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            const Text(
              'Información Personal',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            _buildTextField(label: 'Nombre(s)', controller: _nombreController),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Apellido Paterno',
              controller: _paternoController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Apellido Materno',
              controller: _maternoController,
            ),
            const SizedBox(height: 32),

            const Text('Datos de Acceso', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Correo Electrónico',
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Contraseña',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 32),

            const Text('Condiciones', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Comisión (%)',
                    controller: _commissionController,
                    keyboardType: TextInputType.number,
                    hint: '50',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Container(/* Spacer or other field */)),
              ],
            ),

            const SizedBox(height: 32),

            // Status Switch
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estado Activo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    activeColor: Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save Logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'GUARDAR CAMBIOS' : 'CREAR EMPLEADO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hint,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
