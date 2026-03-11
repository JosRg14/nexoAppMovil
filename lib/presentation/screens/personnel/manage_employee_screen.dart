import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/personnel_api.dart';

class ManageEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const ManageEmployeeScreen({super.key, this.employee});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _paternoController = TextEditingController();
  final _maternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _commissionController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  // Estado para mostrar/ocultar contraseña
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Auto-llenado si estamos en modo edición
    if (widget.employee != null) {
      _nombreController.text =
          widget.employee!['nombre'] ?? widget.employee!['name'] ?? '';
      _paternoController.text =
          widget.employee!['app_paterno'] ??
          widget.employee!['apellido_paterno'] ??
          '';
      _maternoController.text =
          widget.employee!['app_materno'] ??
          widget.employee!['apellido_materno'] ??
          '';

      _correoController.text =
          widget.employee!['correo'] ??
          widget.employee!['usuario']?['correo'] ??
          '';

      _commissionController.text =
          widget.employee!['comision']?.toString() ?? '50';
      _isActive =
          widget.employee!['estado'] == 'activo' ||
          widget.employee!['status'] == 'Activo';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  // --- VALIDACIONES ---

  bool _isEmailValid(String email) {
    if (email.contains(' ')) return false;
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  bool _isPasswordComplex(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasDigits;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Este campo es obligatorio';
    final trimmed = value.trim();
    if (trimmed.length < 3) return 'Mínimo 3 letras';
    final nameRegExp = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$");
    if (!nameRegExp.hasMatch(trimmed)) {
      return 'No se permiten números ni símbolos';
    }
    return null;
  }

  String? _validateCommission(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    final n = double.tryParse(value);
    if (n == null) return 'Debe ser un número';
    if (n < 0 || n > 100) return 'Rango válido: 0 a 100';
    return null;
  }

  // --- LÓGICA DE GUARDADO ---

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = PersonnelApi();

      final nombre = _nombreController.text.trim();
      final appPaterno = _paternoController.text.trim();
      final appMaterno = _maternoController.text.trim();
      final correo = _correoController.text.trim();
      final password = _passwordController.text;
      final comisionVal = double.tryParse(_commissionController.text) ?? 0.0;
      String estadoStr = _isActive ? 'activo' : 'inactivo';

      if (widget.employee == null) {
        // --- MODO REGISTRO ---
        final success = await api.registerEmpleado(
          nombre: nombre,
          appPaterno: appPaterno,
          appMaterno: appMaterno,
          correo: correo,
          password: password,
          comision: comisionVal,
          estado: estadoStr,
        );

        if (success && mounted) {
          _showSnackBar('Empleado creado exitosamente', Colors.green);
          Navigator.pop(context, true); // Retorna true para refrescar la lista
        } else if (mounted) {
          _showSnackBar('No se pudo registrar el empleado', Colors.red);
        }
      } else {
        // --- MODO EDICIÓN ---
        final String? employeeId =
            widget.employee!['id_empleado']?.toString() ??
            widget.employee!['id']?.toString();

        if (employeeId == null) {
          _showSnackBar('Error: ID no encontrado', Colors.red);
          return;
        }

        final success = await api.updateEmpleado(
          id: employeeId,
          nombre: nombre,
          appPaterno: appPaterno,
          appMaterno: appMaterno,
          correo: correo,
          comision: comisionVal,
          estado: estadoStr,
          // La contraseña no se envía al editar
        );

        if (success && mounted) {
          _showSnackBar('Empleado actualizado exitosamente', Colors.green);
          Navigator.pop(context, true); // Retorna true para refrescar la lista
        } else if (mounted) {
          _showSnackBar('No se pudo actualizar el empleado', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Empleado' : 'Nuevo Empleado',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información Personal',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nombre(s)',
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Apellido Paterno',
                controller: _paternoController,
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Apellido Materno',
                controller: _maternoController,
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
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
                  if (!_isEmailValid(value.trim()))
                    return 'Correo inválido o con espacios';
                  return null;
                },
              ),

              // Si no está editando, mostramos la contraseña
              if (!isEditing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintStyle: const TextStyle(color: Colors.white24),
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                  validator: (value) {
                    if (value == null || value.length < 8)
                      return 'Mínimo 8 caracteres';
                    if (!_isPasswordComplex(value))
                      return 'Usa una mayúscula y un número';
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),
              const Text('Condiciones', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Comisión (%)',
                controller: _commissionController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                hint: '50',
                validator: _validateCommission,
              ),

              const SizedBox(height: 32),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hint,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        labelStyle: TextStyle(color: Colors.grey[400]),
        errorStyle: const TextStyle(color: Colors.redAccent),
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
