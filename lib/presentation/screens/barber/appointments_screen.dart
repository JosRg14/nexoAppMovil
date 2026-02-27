import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/barber/service_in_progress_screen.dart';
import 'package:nexoappapp/presentation/widgets/nexo_header.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _activeAppointment;

  Future<void> _handleServiceNavigation(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceInProgressScreen(appointment: appointment),
      ),
    );

    // If result is true, the service was finished
    if (result == true) {
      setState(() {
        _activeAppointment = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data to duplicate the wireframe rows
    final appointments = [
      {
        'service': 'Corte + Barba',
        'price': '\$31',
        'date': '30/01/26 - 6:19pm',
      },
      {
        'service': 'Corte + Barba',
        'price': '\$31',
        'date': '30/01/26 - 6:40pm',
      },
      {
        'service': 'Corte + Barba',
        'price': '\$31',
        'date': '30/01/26 - 7:00pm',
      },
    ];

    final reviews = [
      {
        'client': 'Carlos M.',
        'service': 'Corte + Barba',
        'rating': 5.0,
        'date': '06/02/26',
        'comment':
            'Excelente servicio, muy profesional. El ambiente es genial.',
      },
      {
        'client': 'Luis G.',
        'service': 'Corte Clásico',
        'rating': 4.0,
        'date': '05/02/26',
        'comment': 'Buen corte, pero tuve que esperar unos minutos extra.',
      },
      {
        'client': 'Ana R.',
        'service': 'Tinte de Barba',
        'rating': 5.0,
        'date': '02/02/26',
        'comment': 'Me encantó el resultado, muy detallista.',
      },
      {
        'client': 'Jorge P.',
        'service': 'Corte Niño',
        'rating': 4.5,
        'date': '01/02/26',
        'comment': 'Muy paciente con mi hijo, volveremos.',
      },
    ];

    final views = [
      // Tab 1: Mis Citas
      ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: appointments.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.grey, height: 32, thickness: 0.5),
        itemBuilder: (context, index) {
          final apt = appointments[index];
          // Check if ANY service is active
          final isLocked = _activeAppointment != null;

          return _AppointmentCard(
            serviceName: apt['service']!,
            price: apt['price']!,
            dateTime: apt['date']!,
            isLocked: isLocked,
            onStart: () {
              setState(() {
                _activeAppointment = apt;
              });
              _handleServiceNavigation(context, apt);
            },
          );
        },
      ),
      // Tab 2: Reseñas
      ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: reviews.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.grey, height: 32, thickness: 0.5),
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _ReviewCard(
            clientName: review['client'] as String,
            serviceName: review['service'] as String,
            rating: (review['rating'] as num).toDouble(),
            date: review['date'] as String,
            comment: review['comment'] as String,
          );
        },
      ),
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
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
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

class _AppointmentCard extends StatelessWidget {
  final String serviceName;
  final String price;
  final String dateTime;
  final bool isLocked;
  final VoidCallback onStart;

  const _AppointmentCard({
    required this.serviceName,
    required this.price,
    required this.dateTime,
    required this.isLocked,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row: Image + Info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[300], // Placeholder grey
            ),
            const SizedBox(width: 16),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName, // "Corte + Barba"
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      price, // "$31"
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateTime, // "30/01/26 - 6:19pm"
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom Row: Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLocked ? null : () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isLocked ? Colors.grey : Colors.white,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'CANCELAR',
                  style: TextStyle(
                    color: isLocked ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLocked ? null : onStart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isLocked ? Colors.grey[800] : null,
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: Text(
                  'INICIAR SERVICIO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLocked ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String clientName;
  final String serviceName;
  final double rating;
  final String date;
  final String comment;

  const _ReviewCard({
    required this.clientName,
    required this.serviceName,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Text(
                clientName.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceName,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          comment,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
