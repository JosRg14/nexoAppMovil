import 'package:flutter/material.dart';

class ManageAppointmentModal extends StatefulWidget {
  final Map<String, dynamic>? appointment;

  const ManageAppointmentModal({super.key, this.appointment});

  @override
  State<ManageAppointmentModal> createState() => _ManageAppointmentModalState();
}

class _ManageAppointmentModalState extends State<ManageAppointmentModal> {
  late String _selectedBarber;
  String? _status;

  final _clientController = TextEditingController();
  final _serviceController = TextEditingController();

  final List<String> _barbers = ['Juan Pérez', 'Carlos Ruiz', 'Ana Lopéz'];

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      // CORRECCIÓN: Usar llaves correctas del API y operadores '??' para evitar nulos
      // Si 'empleado' es null, usamos el primero de la lista por defecto
      _selectedBarber =
          widget.appointment!['empleado']?['nombre'] ?? _barbers.first;
      _status = widget.appointment!['estado']?.toString() ?? 'Pendiente';
    } else {
      _selectedBarber = _barbers.first;
      _status = 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

    // Extraemos datos anidados de forma segura para la UI
    final String nombreCliente =
        widget.appointment?['cliente']?['nombre'] ?? 'Cliente Desconocido';
    final String nombreServicio =
        widget.appointment?['servicio']?['nombre_servicio'] ?? 'Sin servicio';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          const SizedBox(height: 24),

          if (isEditing)
            Row(
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
                      nombreCliente, // Variable segura creada arriba
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nombreServicio, // Variable segura creada arriba
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
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
            ),

          const SizedBox(height: 32),
          const Text(
            'Barbero Asignado',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _barbers.contains(_selectedBarber)
                    ? _selectedBarber
                    : _barbers.first,
                dropdownColor: const Color(0xFF2C2C2C),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                items: _barbers
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBarber = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (isEditing && _status?.toLowerCase() != 'cancelado')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                ),
                icon: const Icon(Icons.block),
                label: const Text('CANCELAR CITA'),
              ),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text(isEditing ? 'GUARDAR CAMBIOS' : 'ASIGNAR CITA'),
            ),
          ),
        ],
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
