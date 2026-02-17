import 'package:flutter/material.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar servicios',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill in your payment details and complete the order.', // Placeholder text from wireframe
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Nombre del servicio
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre del servicio',
                hintText: 'Ej. Corte de Cabello',
              ),
            ),
            const SizedBox(height: 24),

            // Descripcion
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descripcion',
                hintText: 'Breve descripción del servicio...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Precio
            const TextField(
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Precio',
                hintText: '\$0.00',
              ),
            ),
            const SizedBox(height: 32),

            // Imagen del servicio (opcional)
            Text(
              'Imagen del servicio (opcional)',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_a_photo,
                color: Colors.grey,
                size: 40,
              ),
            ),
            const SizedBox(height: 48),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Add Logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF2C2C2C,
                  ), // Dark button from wireframe
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agregar Servicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
