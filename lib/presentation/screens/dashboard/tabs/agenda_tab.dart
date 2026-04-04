import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/widgets/manage_appointment_modal.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';

class AgendaTab extends StatefulWidget {
  const AgendaTab({super.key});

  @override
  State<AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  List<dynamic> appointments = [];
  bool isLoading = true;
  int selectedDateIndex = 0;

  // Generar los próximos 7 días empezando desde hoy
  late List<DateTime> next7Days;
  final List<String> monthNames = [
    '',
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    next7Days = List.generate(7, (index) => today.add(Duration(days: index)));
    _fetchAppointmentsForSelectedDate();
  }

  Future<void> _fetchAppointmentsForSelectedDate() async {
    setState(() => isLoading = true);

    // Instancia de API
    final api = AppointmentsApi();
    final data = await api.getAppointmentsByDate(next7Days[selectedDateIndex]);

    if (mounted) {
      setState(() {
        appointments = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                const ManageAppointmentModal(appointment: null),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Agenda Maestra',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Asigna y gestiona las citas de hoy',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date Selector (Horizontal Scroll)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: next7Days.length,
              itemBuilder: (context, index) {
                final date = next7Days[index];
                final isSelected = index == selectedDateIndex;

                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      setState(() => selectedDateIndex = index);
                      _fetchAppointmentsForSelectedDate();
                    }
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          monthNames[date.month],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Appointments List or Loader
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : appointments.isEmpty
                ? const Center(
                    child: Text(
                      "No hay citas para este día.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: appointments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _AgendaCard(appointment: appointments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const _AgendaCard({required this.appointment});

  Map<String, String> _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return {'time': '--:--', 'period': ''};
    }

    final parts = timeStr.split(':');
    if (parts.length < 2) return {'time': timeStr, 'period': ''};

    try {
      int hour = int.parse(parts[0]);
      final String minute = parts[1];
      final String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return {
        'time': '${hour.toString().padLeft(2, '0')}:$minute',
        'period': period,
      };
    } catch (e) {
      return {'time': timeStr, 'period': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Estado de la cita basado exactamente en "estado" del JSON
    final status = appointment['estado']?.toString().toLowerCase() ?? '';
    Color statusColor;

    switch (status) {
      case 'confirmada':
      case 'confirmado':
        statusColor = Colors.greenAccent;
        break;
      case 'pendiente':
        statusColor = Colors.orangeAccent;
        break;
      case 'cancelada':
      case 'cancelado':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    // 2. Extracción de datos del JSON
    final timeData = _formatTime(appointment['hora_inicio']);
    final cliente = appointment['cliente'];
    final empleado = appointment['empleado'];
    final servicio = appointment['servicio'];

    // 3. Manejo seguro de los textos a renderizar
    final String nombreCliente = cliente != null
        ? '${cliente['nombre'] ?? ''} ${cliente['app_paterno'] ?? ''}'.trim()
        : 'Desconocido';

    final String nombreServicio = servicio != null
        ? servicio['nombre_servicio'] ?? 'Sin servicio'
        : 'Sin servicio';

    final String nombreEmpleado = empleado != null
        ? (empleado['nombre']?.toString().split(' ').first ?? 'N/A')
        : 'N/A';

    return GestureDetector(
      onTap: () async {
        final _AgendaTabState state = context
            .findAncestorStateOfType<_AgendaTabState>()!;
        // 1. Guardamos el resultado del modal en una variable
        final result = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              ManageAppointmentModal(appointment: appointment),
        );

        // 2. Si el modal devolvió 'true', refrescamos la lista
        if (result == true) {
          state._fetchAppointmentsForSelectedDate();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  timeData['time']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeData['period']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(width: 1, height: 40, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreCliente.isEmpty ? 'Desconocido' : nombreCliente,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nombreServicio,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 16, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  nombreEmpleado,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
