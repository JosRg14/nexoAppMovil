import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';
import 'package:nexoappapp/presentation/screens/dashboard/appointments/cancel_appointment_screen.dart';

class ManageAppointmentModal extends StatefulWidget {
  final Map<String, dynamic>? appointment;

  const ManageAppointmentModal({super.key, this.appointment});

  @override
  State<ManageAppointmentModal> createState() => _ManageAppointmentModalState();
}

class _ManageAppointmentModalState extends State<ManageAppointmentModal> {
  final AppointmentsApi _api = AppointmentsApi();
  bool _isSaving = false;

  // Datos de la API
  List<Map<String, dynamic>> _activeBarbers = [];
  bool _isLoadingBarbers = true;

  // Estado del formulario
  int? _selectedBarberId;
  String? _status;

  final _clientController = TextEditingController();
  final _serviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final barbers = await _api.getActiveEmployees();

    if (mounted) {
      setState(() {
        _activeBarbers = barbers;
        _isLoadingBarbers = false;

        if (widget.appointment != null) {
          // Si editamos, buscamos el ID del empleado actual en la lista
          _selectedBarberId = widget.appointment!['empleado_id'];
          _status = widget.appointment!['estado']?.toString();
          _clientController.text =
              widget.appointment!['cliente']?['nombre'] ?? '';
          _serviceController.text =
              widget.appointment!['servicio']?['nombre_servicio'] ?? '';
        } else {
          _status = 'pendiente';
        }
      });
    }
  }

  Future<void> _saveChanges(bool isEditing) async {
    if (!isEditing || widget.appointment == null) return;

    final int idCita = widget.appointment!['id_cita'];
    final int? originalEmpleadoId = widget.appointment!['empleado_id'];

    // Si no hubo cambios, simplemente cerramos sin hacer ruido
    if (_selectedBarberId == originalEmpleadoId) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    // Llamada a la API
    final result = await _api.updateAppointment(idCita, {
      'empleado_id': _selectedBarberId,
    });

    if (mounted) {
      setState(() => _isSaving = false);

      // Mostramos el SnackBar (el aviso)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        ),
      );

      // Se cierra el modal independientemente del resultado para no interferir con el SnackBar
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;
    final String nombreCliente =
        widget.appointment?['cliente']?['nombre'] ?? 'Nuevo Cliente';
    final String nombreServicio =
        widget.appointment?['servicio']?['nombre_servicio'] ?? 'Sin servicio';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isEditing),
          const SizedBox(height: 24),

          if (isEditing)
            _buildClientInfo(nombreCliente, nombreServicio)
          else
            _buildNewAppointmentFields(),

          const SizedBox(height: 32),
          const Text(
            'Barbero Asignado',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),

          _buildBarberDropdown(),

          const SizedBox(height: 24),
          if (isEditing && _status?.toLowerCase() != 'cancelada')
            _buildCancelButton(),
          const SizedBox(height: 16),
          _buildSubmitButton(isEditing),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'Gestionar Cita' : 'Asignar Nueva Cita',
          style: const TextStyle(
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

  Widget _buildClientInfo(String nombre, String servicio) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(servicio, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildNewAppointmentFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Nombre del Cliente',
          controller: _clientController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Servicio',
          controller: _serviceController,
          icon: Icons.cut_outlined,
        ),
      ],
    );
  }

  Widget _buildBarberDropdown() {
    if (_isLoadingBarbers) return const LinearProgressIndicator();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value:
              _activeBarbers.any((b) => b['id_empleado'] == _selectedBarberId)
              ? _selectedBarberId
              : null,
          dropdownColor: const Color(0xFF2C2C2C),
          isExpanded: true,
          hint: const Text(
            "Selecciona un barbero",
            style: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
          items: _activeBarbers.map((b) {
            return DropdownMenuItem<int>(
              value: b['id_empleado'],
              child: Text(b['nombre'] + ' ' + b['app_paterno'] ?? 'S/N'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedBarberId = val),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          // 1. Navegamos a la pantalla de cancelación
          // Pasamos el widget.appointment que ya tenemos en el modal
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CancelAppointmentScreen(appointment: widget.appointment!),
            ),
          );

          // 2. Si la pantalla de cancelación devolvió 'true' (se canceló con éxito)
          if (result == true && mounted) {
            // Cerramos el modal actual enviando 'true'
            // Esto hará que AgendaTab ejecute su onRefresh
            Navigator.pop(context, true);
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          foregroundColor: Colors.redAccent,
        ),
        icon: const Icon(Icons.block),
        label: const Text('CANCELAR CITA'),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => _saveChanges(isEditing),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey[400],
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
            : Text(isEditing ? 'GUARDAR CAMBIOS' : 'ASIGNAR CITA'),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
      ),
    );
  }
}
