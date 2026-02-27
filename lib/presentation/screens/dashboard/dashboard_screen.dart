import 'package:flutter/material.dart';
import 'package:nexoappapp/presentation/screens/dashboard/tabs/services_tab.dart';
import 'package:nexoappapp/presentation/screens/dashboard/tabs/personnel_tab.dart';
import 'package:nexoappapp/presentation/screens/dashboard/tabs/agenda_tab.dart';
import 'package:nexoappapp/presentation/widgets/nexo_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const ServicesTab(),
    const PersonnelTab(),
    const AgendaTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const NexoHeader(),
      body: SafeArea(
        child: Column(
          children: [
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
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
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
