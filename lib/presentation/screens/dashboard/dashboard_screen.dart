import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/dashboard/tabs/services_tab.dart';
import 'package:nexoappapp/presentation/screens/dashboard/tabs/personnel_tab.dart';
import 'package:nexoappapp/presentation/screens/dashboard/tabs/agenda_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Placeholder views for now, as requested by the user.
  // "Agenda" (Index 3) could be the AppointmentsScreen we just made,
  // but keeping it simple for now until confirmed.
  final List<Widget> _views = [
    const ServicesTab(),
    const PersonnelTab(),
    const AgendaTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header "NEXOAPP"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                'NEXOAPP',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            // Main Content Area
            Expanded(child: _views[_currentIndex]),
          ],
        ),
      ),
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
          backgroundColor: Colors.black, // Dark Luxury background
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
              icon: Icon(Icons.store_mall_directory_outlined),
              activeIcon: Icon(Icons.store_mall_directory),
              label: 'SERVICIOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'PERSONAL',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'AGENDA',
            ),
          ],
        ),
      ),
    );
  }
}
