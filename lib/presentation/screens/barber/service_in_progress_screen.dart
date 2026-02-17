import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/barber/service_evidence_screen.dart';

class ServiceInProgressScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const ServiceInProgressScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'NEXOAPP',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon/Animation
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orangeAccent, width: 2),
              ),
              child: const Icon(
                Icons.cut,
                size: 64,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 32),

            // Status Text
            Text(
              'En Proceso',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Service Details
            Text(
              appointment['service'],
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              appointment['price'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Finish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to evidence screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceEvidenceScreen(appointment: appointment),
                    ),
                  );

                  // If evidence completed (returned true), propogate completion
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'FINALIZAR SERVICIO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
