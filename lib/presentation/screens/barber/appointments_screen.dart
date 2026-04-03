import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/barber/service_in_progress_screen.dart';
import 'package:nexoappapp/presentation/widgets/nexo_header.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';
import 'package:nexoappapp/presentation/screens/dashboard/appointments/cancel_appointment_screen.dart';
import 'package:nexoappapp/presentation/screens/barber/reviews_employee.dart'; // Import crucial

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _activeAppointment;
  late Future<List<dynamic>> _weeklyAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _weeklyAppointmentsFuture = _fetchNext7Days();
  }

  Future<List<dynamic>> _fetchNext7Days() async {
    final api = AppointmentsApi();
    final now = DateTime.now();
    final futures = List.generate(7, (i) {
      final targetDate = now.add(Duration(days: i));
      return api.getAppointmentsByDate(targetDate);
    });
    final results = await Future.wait(futures);
    return results.expand((x) => x).toList();
  }

  Future<void> _handleServiceNavigation(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) async {
    final int idCita = appointment['id_cita'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    final api = AppointmentsApi();
    final success = await api.iniciarCita(idCita);

    if (context.mounted) Navigator.pop(context);

    if (success) {
      if (!context.mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ServiceInProgressScreen(appointment: appointment),
        ),
      );
      if (result == true) {
        setState(() {
          _activeAppointment = null;
          _weeklyAppointmentsFuture = _fetchNext7Days();
        });
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo iniciar el servicio."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String rawDate) {
    final parts = rawDate.split('T')[0].split('-');
    return parts.length == 3 ? "${parts[2]}/${parts[1]}/${parts[0]}" : rawDate;
  }

  @override
  Widget build(BuildContext context) {
    // VISTA 1: Lógica de Citas
    final misCitasTab = FutureBuilder<List<dynamic>>(
      future: _weeklyAppointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error al cargar citas',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return const Center(
            child: Text(
              'No tienes citas para esta semana',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final apt = appointments[index] as Map<String, dynamic>;
            final previousApt = index > 0
                ? appointments[index - 1] as Map<String, dynamic>
                : null;
            final currentDate = apt['fecha'].toString().split('T')[0];
            final previousDate = previousApt != null
                ? previousApt['fecha'].toString().split('T')[0]
                : '';
            final isNewDay = currentDate != previousDate;
            final isLocked = _activeAppointment != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNewDay) ...[
                  if (index > 0) const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(currentDate),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4,
                        margin: const EdgeInsets.only(
                          left: 8,
                          right: 16,
                          top: 4,
                          bottom: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: _AppointmentCard(
                          appointment: apt,
                          isLocked: isLocked,
                          onStart: () {
                            setState(() => _activeAppointment = apt);
                            _handleServiceNavigation(context, apt);
                          },
                          onRefresh: () => setState(
                            () => _weeklyAppointmentsFuture = _fetchNext7Days(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );

    // Lista de vistas (Navegación)
    final views = [
      misCitasTab,
      const ReviewsEmployeeScreen(), // Viene del otro archivo
    ];

    return Scaffold(
      appBar: const NexoHeader(),
      body: views[_currentIndex],
      floatingActionButton: _activeAppointment != null
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _handleServiceNavigation(context, _activeAppointment!),
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.access_time_filled, color: Colors.white),
              label: const Text(
                'VOLVER AL SERVICIO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'MIS CITAS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: 'RESEÑAS',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget privado para la tarjeta de citas
class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isLocked;
  final VoidCallback onStart;
  final VoidCallback onRefresh;

  const _AppointmentCard({
    required this.appointment,
    required this.isLocked,
    required this.onStart,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final servicio = appointment['servicio'] ?? {};
    final cliente = appointment['cliente'] ?? {};
    final estado =
        appointment['estado']?.toString().toLowerCase() ?? 'pendiente';
    final serviceName =
        servicio['nombre_servicio'] ?? 'Servicio no especificado';
    final price = '\$${servicio['precio'] ?? '0.00'}';
    final clientName =
        '${cliente['nombre'] ?? 'Desconocido'} ${cliente['app_paterno'] ?? ''}'
            .trim();
    String startTime = appointment['hora_inicio'] ?? '00:00';
    if (startTime.length > 5) startTime = startTime.substring(0, 5);
    final date = appointment['fecha']?.toString().split('T')[0] ?? 'Sin fecha';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                clientName,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                "$date - $startTime hrs",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionSection(context, estado),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, String estado) {
    if (estado == 'completada')
      return _statusBanner(
        'LA CITA FUE COMPLETADA',
        Colors.white24,
        Colors.white,
      );
    if (estado == 'cancelada')
      return _statusBanner(
        'LA CITA FUE CANCELADA',
        Colors.redAccent.withOpacity(0.1),
        Colors.redAccent,
      );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLocked
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CancelAppointmentScreen(appointment: appointment),
                      ),
                    );
                    if (result == true) onRefresh();
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isLocked ? Colors.grey : Colors.white),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              'CANCELAR',
              style: TextStyle(color: isLocked ? Colors.grey : Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLocked ? null : onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked ? Colors.grey[800] : Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              estado == 'en_proceso' ? 'CONTINUAR' : 'INICIAR SERVICIO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBanner(String text, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: textColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
