import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/services/add_service_screen.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final services = [
      {
        'name': 'Corte ejecutivo',
        'desc': 'Packed Bags\nQuantity: 1',
        'price': '\$31',
      },
      {
        'name': 'Corte clásico',
        'desc': 'Packed Bags\nQuantity: 1',
        'price': '\$31',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Uses Dashboard Scaffold background
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('AGREGAR'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Mis servicios',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lista de tus servicios dentro de tu negocio',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // List
            Expanded(
              child: ListView.separated(
                itemCount: services.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        0,
                      ), // Rectangular as per wireframe card
                    ),
                    child: Row(
                      children: [
                        // Image Placeholder
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['name']!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service['desc']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Text(
                          service['price']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
