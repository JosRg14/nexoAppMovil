import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/widgets/manage_appointment_modal.dart';

class AgendaTab extends StatefulWidget {
  const AgendaTab({super.key});

  @override
  State<AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<AgendaTab> {
  // Dummy Data for Today's Appointments
  final appointments = [
    {
      'time': '10:00 AM',
      'client': 'Roberto Gomez',
      'service': 'Corte Clásico',
      'barber': 'Juan Pérez',
      'status': 'Confirmado',
    },
    {
      'time': '11:30 AM',
      'client': 'Mario Diaz',
      'service': 'Barba + Masaje',
      'barber': 'Carlos Ruiz',
      'status': 'Pendiente',
    },
    {
      'time': '02:00 PM',
      'client': 'Luis Torres',
      'service': 'Corte Niño',
      'barber': 'Juan Pérez',
      'status': 'Confirmado',
    },
    {
      'time': '04:15 PM',
      'client': 'Jose Martinez',
      'service': 'Tinte',
      'barber': 'Ana Lopéz',
      'status': 'Cancelado',
    },
  ];

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
              itemCount: 7, // Next 7 days
              itemBuilder: (context, index) {
                final isSelected = index == 0; // Today selected by default
                return Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.grey[800]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ENE',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${30 + index}', // Dummy dates
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Appointments List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: appointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'];
    Color statusColor;
    switch (status) {
      case 'Confirmado':
        statusColor = Colors.greenAccent;
        break;
      case 'Pendiente':
        statusColor = Colors.orangeAccent;
        break;
      case 'Cancelado':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              ManageAppointmentModal(appointment: appointment),
        );
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
            // Time
            Column(
              children: [
                Text(
                  appointment['time'].split(' ')[0], // "10:00"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appointment['time'].split(' ')[1], // "AM"
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Divider
            Container(width: 1, height: 40, color: Colors.grey[700]),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['client'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    appointment['service'],
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),

            // Barber Avatar (Assigned)
            Column(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 16, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment['barber'].split(' ')[0], // First name
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
