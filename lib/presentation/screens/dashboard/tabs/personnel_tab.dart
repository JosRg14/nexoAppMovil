import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/personnel/manage_employee_screen.dart';

class PersonnelTab extends StatelessWidget {
  const PersonnelTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final employees = [
      {
        'name': 'Juan Pérez',
        'role': 'Barbero Senior',
        'status': 'Activo',
        'color': Colors.blueAccent,
      },
      {
        'name': 'Carlos Ruiz',
        'role': 'Barbero',
        'status': 'Activo',
        'color': Colors.greenAccent,
      },
      {
        'name': 'Ana Lopéz',
        'role': 'Recepcionista',
        'status': 'Inactivo',
        'color': Colors.orangeAccent,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageEmployeeScreen(),
            ),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: SingleChildScrollView(
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

            // Employee List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _EmployeeCard(employee: emp),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;

  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            employee['name'][0], // Initials
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(employee['role'], style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: employee['status'] == 'Activo'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  employee['status'],
                  style: TextStyle(
                    color: employee['status'] == 'Activo'
                        ? Colors.greenAccent
                        : Colors.redAccent,
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
            );
          },
        ),
      ),
    );
  }
}
