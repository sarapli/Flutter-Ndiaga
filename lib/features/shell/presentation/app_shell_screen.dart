import 'package:flutter/material.dart';

import '../../../screens/appointments_screen.dart';
import '../../../screens/chat_screen.dart';
import '../../../screens/doctors_list_screen.dart';
import '../../dashboard/presentation/patient_dashboard_screen.dart';
import '../../dashboard/presentation/doctor_dashboard_screen.dart';
import '../../../screens/settings_screen.dart';

enum ShellRole { patient, doctor }

class AppShellScreen extends StatefulWidget {
  final ShellRole role;

  const AppShellScreen({super.key, required this.role});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.role == ShellRole.doctor ? const DoctorDashboardScreen() : const PatientDashboardScreen();

    final pages = <Widget>[
      dashboard,
      const DoctorsListScreen(),
      const AppointmentsScreen(showBottomBar: false),
      const ChatScreen(),
      const SettingsScreen(showBottomBar: false),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFE7F3F1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.medical_information_outlined), selectedIcon: Icon(Icons.medical_information), label: 'Doctors'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Appointments'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
