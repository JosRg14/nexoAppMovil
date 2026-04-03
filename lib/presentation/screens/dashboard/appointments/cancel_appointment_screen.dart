import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/widgets/nexo_header.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';

class CancelAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const CancelAppointmentScreen({super.key, required this.appointment});

  @override
  State<CancelAppointmentScreen> createState() =>
      _CancelAppointmentScreenState();
}

class _CancelAppointmentScreenState extends State<CancelAppointmentScreen> {
  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _showOtherInput = false;
  bool _isLoading = false; // <-- Nuevo estado para el loading

  void _selectReason(String reason, {bool isOther = false}) {
    setState(() {
      _selectedReason = reason;
      _showOtherInput = isOther;
      if (!isOther) _otherReasonController.clear();
    });
  }

  // Método para manejar la petición a la API
  Future<void> _procesarCancelacion() async {
    setState(() => _isLoading = true);

    final api = AppointmentsApi();
    final int idCita = widget.appointment['id_cita'];
    bool success = false;

    // Evaluamos qué ruta de Laravel usar
    if (_selectedReason == "Cliente no se presentó") {
      // Ruta: /citas/{id}/no-asistio
      success = await api.marcarNoAsistio(idCita);
    } else {
      // Ruta: /citas/{id}/cancelar
      final motivo = _otherReasonController.text.trim();
      success = await api.cancelarCita(idCita, motivo);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Si todo sale bien en Laravel, regresamos 'true' a la pantalla anterior
      // Esto le dirá a AppointmentsScreen que debe recargar la lista
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ocurrió un error. Verifica el estado de la cita."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.appointment['cliente'] ?? {};
    final clientName =
        "${cliente['nombre'] ?? 'Cliente'} ${cliente['app_paterno'] ?? ''}";

    // Validamos que se pueda habilitar el botón
    final bool isFormValid =
        (_selectedReason == "Cliente no se presentó") ||
        (_showOtherInput && _otherReasonController.text.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const NexoHeader(), // Tu header
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CANCELAR CITA",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "¿Por qué deseas cancelar la cita de $clientName?",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),

            _ReasonTile(
              label: "Cliente no se presentó",
              isSelected: _selectedReason == "Cliente no se presentó",
              onTap: _isLoading
                  ? () {}
                  : () => _selectReason("Cliente no se presentó"),
            ),
            const SizedBox(height: 16),

            _ReasonTile(
              label: "Otro motivo...",
              isSelected: _showOtherInput,
              onTap: _isLoading
                  ? () {}
                  : () => _selectReason("Otro", isOther: true),
            ),

            if (_showOtherInput) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otherReasonController,
                maxLines: 3,
                enabled: !_isLoading, // Bloqueamos el input si está cargando
                onChanged: (value) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Escribe el motivo aquí...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      "REGRESAR",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    // Si no es válido o está cargando, se deshabilita
                    onPressed: (!isFormValid || _isLoading)
                        ? null
                        : _procesarCancelacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      disabledBackgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                        : const Text(
                            "CONFIRMAR",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para los botones de motivo
class _ReasonTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[900],
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.orange)
            else
              const Icon(Icons.circle_outlined, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
