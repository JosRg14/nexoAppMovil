import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/services/add_service_screen.dart';
import 'package:nexoappapp/api_connect/services_api.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  List<dynamic> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);

    final api = ServicesApi();
    final data = await api.getServices();

    if (mounted) {
      setState(() {
        _services = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
          ).then((value) => _fetchServices());
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('AGREGAR'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchServices,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Mis servicios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lista de tus servicios dentro de tu negocio',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _services.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay servicios",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _services.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return _ServiceCard(service: service);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "https://devlink-servidorapi.td60xq.easypanel.host";

    final String name = service['nombre'] ?? 'Sin nombre';
    final String duration = "${service['duracion'] ?? 0} min";
    final String price = "\$${service['precio']}";

    // Concatenamos la URL base con la ruta de la API
    final String? relativePath = service['imagen'];
    final String fullImageUrl = (relativePath != null)
        ? "$baseUrl$relativePath"
        : "";

    // --- LÓGICA DE LA COMISIÓN ---
    final comisionData = service['comision'];
    final bool hasComision =
        comisionData != null && comisionData['tipo'] != 'ninguna';
    final String comisionDesc = hasComision
        ? (comisionData['descripcion'] ?? 'CON COMISIÓN')
        : 'SIN COMISIÓN';

    final activeColor = const Color(0xFF25B5DA); // Cyan/Azul
    final inactiveColor = const Color(0xFF9CA3AF); // Gris texto
    final inactiveBorder = const Color(0xFF374151); // Gris borde/fondo

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Fondo oscuro de la tarjeta
        borderRadius: BorderRadius.circular(
          12,
        ), // Un poco más redondeado como en la imagen 1
        border: Border.all(color: Colors.grey[800]!), // Borde gris sutil
      ),
      // --- COLUMNA PRINCIPAL DE LA ESTRUCTURA ---
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA 1 (SUPERIOR): EL NOMBRE DEL SERVICIO (Ocupa todo el ancho)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              name.toUpperCase(), // Mayúsculas
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              maxLines: 2, // Permite 2 líneas si es muy largo
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // FILA 2 (MEDIO/INFERIOR): DIVIDIDA EN TRES COLUMNAS SEGÚN EL PAINT
          IntrinsicHeight(
            // Esto hace que las 3 columnas tengan la misma altura
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // COLUMNA 1 (IZQUIERDA): IMAGEN
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: fullImageUrl.isNotEmpty
                        ? Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[850],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[850],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // COLUMNA 2 (CENTRAL): DURACIÓN Y COMISIÓN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DURACIÓN (Un poco más abajo del centro de la imagen)
                      // const Spacer(), // Empuja hacia abajo
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Aire antes de la comisión
                      // BADGE DE COMISIÓN (ESTILO TAILWIND)
                      // Ahora dentro de Column central, tiene espacio para crecer verticalmente
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasComision
                              ? activeColor.withOpacity(0.1)
                              : inactiveBorder.withOpacity(0.3),
                          border: Border.all(
                            color: hasComision
                                ? activeColor.withOpacity(0.3)
                                : inactiveBorder,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasComision
                                  ? Icons.payments_outlined
                                  : Icons.money_off,
                              color: hasComision ? activeColor : inactiveColor,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            // Usamos flexible para que el texto no desborde horizontalmente
                            Flexible(
                              child: Text(
                                comisionDesc.toUpperCase(),
                                style: TextStyle(
                                  color: hasComision
                                      ? activeColor
                                      : inactiveColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // COLUMNA 3 (DERECHA): PRECIO
                Align(
                  alignment: Alignment
                      .center, // Centrado verticalmente respecto a la imagen
                  child: Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "https://devlink-servidorapi.td60xq.easypanel.host";

    final String name = service['nombre'] ?? 'Sin nombre';
    // Usamos la descripción si existe, para que se parezca más a la imagen
    final String description =
        service['descripcion'] ?? "${service['duracion'] ?? 0} min";
    final String price = "\$${service['precio']}";

    // Concatenamos la URL base con la ruta de la API
    final String? relativePath = service['imagen'];
    final String fullImageUrl = (relativePath != null)
        ? "$baseUrl$relativePath"
        : "";

    // --- LÓGICA DE LA COMISIÓN ---
    // Asegúrate de que tu API de Laravel esté enviando este objeto 'comision'
    final comisionData = service['comision'];
    final bool hasComision =
        comisionData != null && comisionData['tipo'] != 'ninguna';
    final String comisionDesc = hasComision
        ? (comisionData['descripcion'] ?? 'CON COMISIÓN')
        : 'SIN COMISIÓN';

    // Colores basados en tu código Laravel / Tailwind
    final activeColor = const Color(0xFF25B5DA); // Cyan/Azul
    final inactiveColor = const Color(0xFF9CA3AF); // Gris texto
    final inactiveBorder = const Color(0xFF374151); // Gris borde/fondo

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Fondo oscuro de la tarjeta
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!), // Borde gris sutil
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IMAGEN
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[850],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: activeColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[850],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // INFO (Nombre, Descripción, Badge)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TÍTULO
                Text(
                  name.toUpperCase(), // Mayúsculas como en la imagen
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // DESCRIPCIÓN
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // BADGE DE COMISIÓN (ESTILO TAILWIND)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasComision
                        ? activeColor.withOpacity(0.1)
                        : inactiveBorder.withOpacity(0.3),
                    border: Border.all(
                      color: hasComision
                          ? activeColor.withOpacity(0.3)
                          : inactiveBorder,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasComision
                            ? Icons.savings_outlined
                            : Icons
                                  .money_off, // Icono similar al hand-holding-dollar
                        color: hasComision ? activeColor : inactiveColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comisionDesc.toUpperCase(),
                        style: TextStyle(
                          color: hasComision ? activeColor : inactiveColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // PRECIO
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22, // Un poco más grande para que destaque
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}*/
