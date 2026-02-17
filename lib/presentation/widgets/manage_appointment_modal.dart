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

  // Controllers for new appointment
  final _clientController = TextEditingController();
  final _serviceController = TextEditingController();

  final List<String> _barbers = ['Juan Pérez', 'Carlos Ruiz', 'Ana Lopéz'];

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _selectedBarber = widget.appointment!['barber'];
      _status = widget.appointment!['status'];
    } else {
      _selectedBarber = _barbers.first;
      _status = 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Gestionar Cita' : 'Asignar Nueva Cita',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
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

          // Client Info (Read-only if editing, Input if new)
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
                      widget.appointment!['client'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.appointment!['service'],
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

          // 1. Assign Barber
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
                value: _selectedBarber,
                dropdownColor: const Color(0xFF2C2C2C),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.person_outline, color: Colors.white),
                items: _barbers.map((barber) {
                  return DropdownMenuItem(value: barber, child: Text(barber));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBarber = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Cancellation Action (Only if Editing)
          if (isEditing) ...[
            if (_status != 'Cancelado')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _status = 'Cancelado');
                    // TODO: Logic to update status
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.block),
                  label: const Text('CANCELAR CITA'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Esta cita ha sido cancelada',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Save/Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'GUARDAR CAMBIOS' : 'ASIGNAR CITA'),
            ),
          ),
          const SizedBox(height: 16), // Bottom padding
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
