import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';
import 'package:nexoappapp/api_connect/services_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexoappapp/presentation/screens/barber/service_evidence_screen.dart';

class CreateQuickServiceModal extends StatefulWidget {
  const CreateQuickServiceModal({super.key});

  @override
  State<CreateQuickServiceModal> createState() =>
      _CreateQuickServiceModalState();
}

class _CreateQuickServiceModalState extends State<CreateQuickServiceModal> {
  final AppointmentsApi _appointmentsApi = AppointmentsApi();
  final ServicesApi _servicesApi = ServicesApi();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEmployee = false;

  // Listas de datos
  List<Map<String, dynamic>> _activeBarbers = [];
  List<dynamic> _services = [];

  // Valores seleccionados
  int? _selectedBarberId;
  int? _selectedServiceId;

  // Controladores y variables de tiempo
  final TextEditingController _priceController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Inicializar con la fecha y hora actuales del sistema
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _loadInitialData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // --- FUNCIONES PRINCIPALES DE LA VISTA ---

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idLogueado = prefs.getInt('id_empleado');

    final results = await Future.wait([
      _appointmentsApi.getActiveEmployees(),
      _servicesApi.getServices(),
    ]);

    if (mounted) {
      setState(() {
        _activeBarbers = results[0] as List<Map<String, dynamic>>;
        _services = results[1] as List<dynamic>;
        _isLoading = false;

        // Autoselección y detección de rol
        if (idLogueado != null) {
          _isEmployee = true;
          _selectedBarberId = idLogueado;
        }
      });
    }
  }

  void _onServiceChanged(int? serviceId) {
    setState(() {
      _selectedServiceId = serviceId;
      if (serviceId != null) {
        // Buscar el servicio seleccionado para extraer su precio
        final selectedService = _services.firstWhere(
          (s) => s['id'] == serviceId,
          orElse: () => null,
        );

        if (selectedService != null) {
          // Actualizar el input de precio dinámicamente
          _priceController.text = selectedService['precio'].toString();
        }
      } else {
        _priceController.clear();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- MÉTODO PARA GUARDAR ---
  Future<void> _saveQuickService() async {
    // 1. Validaciones
    if (_selectedServiceId == null) {
      _showSnackBar('Por favor selecciona un servicio', isError: true);
      return;
    }

    if (_selectedBarberId == null) {
      _showSnackBar('Por favor selecciona quién atendió', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    // 2. Formatear la fecha y hora para la API
    final String fechaFormat =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final String horaFormat =
        "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    // 3. Preparar el precio
    double? precioFinal;
    if (_priceController.text.isNotEmpty) {
      precioFinal = double.tryParse(_priceController.text);
    }

    final String estadoInicial = _isEmployee ? 'completada' : 'pendiente';

    // 4. Armar el payload
    final Map<String, dynamic> payload = {
      'empleado_id': _selectedBarberId,
      'servicio_id': _selectedServiceId,
      'fecha': fechaFormat,
      'hora_inicio': horaFormat,
      'precio': precioFinal,
      'estado': estadoInicial,
    };

    // 5. Enviar a la API
    final result = await _appointmentsApi.createWalkInService(payload);

    if (mounted) {
      setState(() => _isSaving = false);

      if (result['success']) {
        final data = result['data'];

        // 1. Cerramos el modal actual notificando éxito para refrescar la lista de atrás
        Navigator.pop(context, true);

        // --- INICIO DE LLAMADA CONDICIONAL A EVIDENCIAS ---

        // Solo redirigimos si el estado devuelto por la API es 'completada'
        if (data['estado'] == 'completada') {
          // Buscamos el nombre del servicio para el mock
          final servicioSeleccionado = _services.firstWhere(
            (s) => s['id'] == _selectedServiceId,
            orElse: () => {'nombre': 'Servicio Rápido'},
          );

          final Map<String, dynamic> mockAppointment = {
            'servicio': {'nombre_servicio': servicioSeleccionado['nombre']},
            'cliente': {
              'nombre': 'Cliente',
              'app_paterno': 'General (Walk-in)',
            },
            'precio_total': data['precio'],
          };

          // Navegamos a la pantalla de evidencias
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceEvidenceScreen(
                appointment: mockAppointment,
                registroId: data['registro_id'],
              ),
            ),
          );
        } else {
          _showSnackBar('Cita registrada como pendiente');
        }
        // --- FIN DE LLAMADA A EVIDENCIAS ---
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        // Mantenemos tu lógica de padding pero agregamos el SingleChildScrollView
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              // <--- AGREGAMOS ESTO
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  _buildLabel('Barbero'),
                  _buildBarberDropdown(),
                  const SizedBox(height: 16),

                  _buildLabel('Servicio Realizado'),
                  _buildServiceDropdown(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Fecha'),
                            _buildDateSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildLabel('Hora'), _buildTimeSelector()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Precio Cobrado (\$)'),
                  _buildPriceField(),
                  const SizedBox(height: 32),

                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Servicio Sin Cita',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildBarberDropdown() {
    return Opacity(
      // Si es empleado, bajamos un poco la opacidad para indicar que está bloqueado
      opacity: _isEmployee ? 0.7 : 1.0,
      child: _buildDropdownContainer(
        child: DropdownButton<int>(
          value:
              _activeBarbers.any((b) => b['id_empleado'] == _selectedBarberId)
              ? _selectedBarberId
              : null,
          dropdownColor: const Color(0xFF2C2C2C),
          isExpanded: true,
          hint: const Text(
            "Selecciona quién atendió",
            style: TextStyle(color: Colors.grey),
          ),
          // Icono diferente si está bloqueado para dar feedback visual
          icon: Icon(
            _isEmployee ? Icons.lock_outline : Icons.arrow_drop_down,
            size: 20,
            color: Colors.grey,
          ),
          style: const TextStyle(color: Colors.white),
          items: _activeBarbers.map((b) {
            return DropdownMenuItem<int>(
              value: b['id_empleado'],
              child: Text("${b['nombre']} ${b['app_paterno'] ?? ''}"),
            );
          }).toList(),
          // Si es empleado, onChanged es null (bloquea el dropdown)
          onChanged: _isEmployee
              ? null
              : (val) => setState(() => _selectedBarberId = val),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    debugPrint(_services.toString());
    return _buildDropdownContainer(
      child: DropdownButton<int>(
        value: _services.any((s) => s['id'] == _selectedServiceId)
            ? _selectedServiceId
            : null,
        dropdownColor: const Color(0xFF2C2C2C),
        isExpanded: true,
        hint: const Text(
          "Selecciona el servicio",
          style: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(color: Colors.white),
        items: _services.map((s) {
          return DropdownMenuItem<int>(
            value: s['id'],
            child: Text(s['nombre']),
          );
        }).toList(),
        onChanged: _onServiceChanged,
      ),
    );
  }

  Widget _buildDateSelector() {
    // Formateo simple DD/MM/YYYY
    final dateStr =
        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return InkWell(
      onTap: () => _selectDate(context),
      child: _buildDropdownContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateStr, style: const TextStyle(color: Colors.white)),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: _buildDropdownContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTime.format(context),
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.access_time, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  // En tu _buildSubmitButton...
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // AQUÍ CONECTAMOS LA FUNCIÓN
        onPressed: _isSaving ? null : _saveQuickService,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'REGISTRAR SERVICIO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
