import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/auth_service.dart';

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
    if (widget.employee != null) {
      _nombreController.text = widget.employee!['name'] ?? '';
      _paternoController.text = widget.employee!['apellido_paterno'] ?? '';
      _maternoController.text = widget.employee!['apellido_materno'] ?? '';
      _correoController.text = widget.employee!['correo'] ?? '';
      _commissionController.text =
          widget.employee!['comision']?.toString() ?? '50';
      _isActive = widget.employee!['status'] == 'Activo';
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
      final api = ApiConnect();

      final nombre = _nombreController.text.trim();
      final appPaterno = _paternoController.text.trim();
      final appMaterno = _maternoController.text.trim();
      final correo = _correoController.text.trim();
      final password = _passwordController.text;
      final comisionVal = double.tryParse(_commissionController.text) ?? 0.0;

      if (widget.employee == null) {
        final success = await api.registerEmpleado(
          nombre: nombre,
          appPaterno: appPaterno,
          appMaterno: appMaterno,
          correo: correo,
          password: password,
          comision: comisionVal,
        );

        if (success && mounted) {
          _showSnackBar('Empleado creado exitosamente', Colors.green);
          Navigator.pop(context);
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
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
              const SizedBox(height: 16),

              // CAMPO DE CONTRASEÑA CON EL OJO
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: isEditing ? '(Opcional al editar)' : null,
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
                  if (isEditing && (value == null || value.isEmpty))
                    return null;
                  if (value == null || value.length < 6)
                    return 'Mínimo 6 caracteres';
                  if (!_isPasswordComplex(value))
                    return 'Usa una mayúscula y un número';
                  return null;
                },
              ),

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
