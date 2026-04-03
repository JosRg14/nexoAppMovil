import 'package:flutter/material.dart';
import 'package:nexoappapp/api_connect/appointments_api.dart';

class ReviewsEmployeeScreen extends StatefulWidget {
  const ReviewsEmployeeScreen({super.key});

  @override
  State<ReviewsEmployeeScreen> createState() => _ReviewsEmployeeScreenState();
}

class _ReviewsEmployeeScreenState extends State<ReviewsEmployeeScreen> {
  late Future<Map<String, dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = AppointmentsApi().getEmployeeReviews();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No hay reseñas aún",
              style: TextStyle(color: Colors.white60),
            ),
          );
        }

        final data = snapshot.data!;
        final List<dynamic> reviews = data['resenas'] ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _reviewsFuture = AppointmentsApi().getEmployeeReviews();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount:
                reviews.length + 1, // +1 para el encabezado de estadísticas
            itemBuilder: (context, index) {
              if (index == 0) return _buildStatsHeader(data);

              final review = reviews[index - 1];
              return _ReviewCard(review: review);
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsHeader(Map<String, dynamic> data) {
    // Extraemos datos del controller de Laravel
    final double promedio = double.tryParse(data['promedio'].toString()) ?? 0.0;
    final int total = data['total_resenas'] ?? 0;
    // Asumimos que calcularValoracion() devuelve un mapa 'conteos' con {5: X, 4: Y...}
    final conteos =
        data['distribucion'] ?? {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Sección Izquierda: Promedio
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  promedio.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text(
                  "Promedio",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  "$total reseñas",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          // Divisor
          Container(
            width: 1,
            height: 80,
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Sección Derecha: Barras de estrellas
          Expanded(
            flex: 3,
            child: Column(
              children: ['5', '4', '3', '2', '1'].map((star) {
                int count = conteos[star] ?? 0;
                double percent = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        star,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.orange, size: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.white10,
                            color: Colors.orange,
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$count",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final cliente = review['cliente'] ?? {};
    final servicio = review['servicio'] ?? {};
    final String nombre = "${cliente['nombre']} ${cliente['app_paterno']}"
        .trim();
    final double rating =
        double.tryParse(review['calificacion'].toString()) ?? 0.0;

    // Formateo rápido de fecha
    String dateLabel = "Reciente";
    if (review['created_at'] != null) {
      DateTime dt = DateTime.parse(review['created_at']);
      dateLabel = "${dt.day}/${dt.month}/${dt.year}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: Text(
                nombre.isNotEmpty ? nombre[0] : "?",
                style: const TextStyle(color: Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    servicio['nombre'] ?? 'Servicio',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              dateLabel,
              style: const TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < rating ? Icons.star : Icons.star_border,
              color: Colors.orange,
              size: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          review['comentario'] ?? '',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: Colors.white10, height: 1),
        ),
      ],
    );
  }
}
