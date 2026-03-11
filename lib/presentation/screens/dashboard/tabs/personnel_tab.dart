import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/personnel/manage_employee_screen.dart';
import 'package:nexoappapp/api_connect/personnel_api.dart';

class PersonnelTab extends StatefulWidget {
  const PersonnelTab({super.key});

  @override
  State<PersonnelTab> createState() => _PersonnelTabState();
}

class _PersonnelTabState extends State<PersonnelTab> {
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  // Función que llamará el RefreshIndicator
  Future<void> _handleRefresh() async {
    await _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    // Si ya estamos cargando, no hacemos nada (evita doble petición)
    setState(() => _isLoading = true);

    try {
      final api = PersonnelApi();
      final data = await api.getEmpleados();

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _employees = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageEmployeeScreen(),
            ),
          ).then((value) {
            // Si regresamos de agregar con éxito (value == true), refrescamos
            if (value == true) {
              _fetchEmployees();
            }
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      // 1. Envolvemos el contenido en el RefreshIndicator para actualizar registros
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Personal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestiona tu equipo de trabajo',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              if (_isLoading && _employees.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_employees.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(80.0),
                    child: Text(
                      'No hay empleados.\nDesliza hacia abajo para actualizar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final emp = _employees[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _EmployeeCard(
                        employee: emp,
                        // Le pasamos la función para que la llame si edita exitosamente
                        onRefresh: _fetchEmployees,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onRefresh; // Agregamos la función de recarga

  const _EmployeeCard({required this.employee, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // 1. Extracción y concatenación segura de nombre completo
    final String nombre = (employee['nombre'] ?? '').toString();
    final String paterno = (employee['app_paterno'] ?? '').toString();
    final String materno = (employee['app_materno'] ?? '').toString();

    final String fullName = '$nombre $paterno $materno'.trim();
    final String displayName = fullName.isNotEmpty
        ? fullName
        : 'Sin nombre registrado';

    // 2. Especialidad y Estado
    final String role = (employee['especialidad'] ?? 'Barbero').toString();

    final String rawStatus =
        employee['estado']?.toString().toLowerCase() ?? 'inactivo';
    final bool isActive = rawStatus == 'activo' || rawStatus == '1';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16.0,
      ), // Margen inferior para separar tarjetas
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[800],
          radius: 25,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(role, style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: isActive ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageEmployeeScreen(employee: employee),
              ),
            ).then((value) {
              // AQUI ESTÁ EL CAMBIO: Si editó correctamente, recarga la lista
              if (value == true) {
                onRefresh();
              }
            });
          },
        ),
      ),
    );
  }
}
