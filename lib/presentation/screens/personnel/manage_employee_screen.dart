import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';

class ManageEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const ManageEmployeeScreen({super.key, this.employee});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  // 1. Agregamos el FormKey para las validaciones
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _paternoController = TextEditingController();
  final _maternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _commissionController = TextEditingController();

  bool _isActive = true;
  // 2. Indicador de carga
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nombreController.text = widget.employee!['name'] ?? '';
      _paternoController.text = widget.employee!['apellido_paterno'] ?? '';
      _maternoController.text = widget.employee!['apellido_materno'] ?? '';
      _correoController.text = widget.employee!['correo'] ?? '';
      _passwordController.text = '';
      _commissionController.text =
          widget.employee!['comision']?.toString() ?? '50';
      _isActive = widget.employee!['status'] == 'Activo';
    }
  }

  @override
  void dispose() {
    // Buena práctica: limpiar los controladores
    _nombreController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  // 3. Función para manejar el guardado
  Future<void> _handleSave() async {
    // Validamos todos los TextFormFields
    if (!_formKey.currentState!.validate()) {
      return; // Si hay errores, no continuamos
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiConnect();

      double comisionVal = double.tryParse(_commissionController.text) ?? 0.0;
      String estadoStr = _isActive ? 'activo' : 'inactivo';

      if (widget.employee == null) {
        // --- MODO CREAR ---

        final success = await api.registerEmpleado(
          nombre: _nombreController.text.trim(),
          appPaterno: _paternoController.text.trim(),
          appMaterno: _maternoController.text.trim(),
          correo: _correoController.text.trim(),
          password:
              _passwordController.text, // La contraseña no suele llevar trim()
          comision: comisionVal,
          // estado: estadoStr, // Si tu API lo acepta
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empleado creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Regresamos a la lista
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear empleado'),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Simulación temporal para que pruebes la UI
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        // --- MODO EDITAR ---
        // TODO: Implementar lógica de edición en el futuro
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocurrió un error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Scaffold(
      backgroundColor: Colors.black, // Fondo general oscuro
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
        // 4. Envolvemos la columna en un Form
        child: Form(
          key: _formKey,
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

              _buildTextField(
                label: 'Nombre(s)',
                controller: _nombreController,
                validator: (value) =>
                    value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Apellido Paterno',
                controller: _paternoController,
                validator: (value) =>
                    value!.isEmpty ? 'El apellido es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Apellido Materno',
                controller: _maternoController,
                // Puede ser opcional, dependiendo de tu regla de negocio
                validator: (value) =>
                    value!.isEmpty ? 'El apellido es obligatorio' : null,
              ),
              const SizedBox(height: 32),

              const Text(
                'Datos de Acceso',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Correo Electrónico',
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El correo es obligatorio';
                  // Validación simple de formato de correo
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (!isEditing && (value == null || value.isEmpty)) {
                    return 'La contraseña es obligatoria para nuevos empleados';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              const Text('Condiciones', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alinea arriba por si hay error
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Comisión (%)',
                      controller: _commissionController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      hint: '50',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (double.tryParse(value) == null)
                          return 'Debe ser un número';
                        return null;
                      },
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

              // Save Button con Indicador de Carga
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor:
                        Colors.grey, // Color cuando está cargando
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isEditing ? 'GUARDAR CAMBIOS' : 'CREAR EMPLEADO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Cambiamos TextField por TextFormField
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hint,
    bool obscureText = false,
    String? Function(String?)? validator, // Añadimos el parámetro validador
  }) {
    return TextFormField(
      // Antes era TextField
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator, // Asignamos el validador
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[400]),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
        ), // Color del texto de error
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
