import 'package:flutter/material.dart';

import '../../../app_style.dart';
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
      bottomNavigationBar: Container
          (
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomNavLogoItem(
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _BottomNavIconItem(
                  icon: Icons.notifications_none_rounded,
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _BottomNavIconItem(
                  icon: Icons.search_rounded,
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _BottomNavIconItem(
                  icon: Icons.article_outlined,
                  selected: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
                _BottomNavIconItem(
                  icon: Icons.grid_view_rounded,
                  selected: _index == 4,
                  onTap: () => setState(() => _index = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavLogoItem extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavLogoItem({super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? const Color(0xFFE7F3F1) : const Color(0xFFF7F8FB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Image.asset(
          'asset/Logo_maquette.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _BottomNavIconItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavIconItem({super.key, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const inactiveColor = Color(0xFF8A8FA3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F3F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 24,
          color: selected ? kPrimaryColor : inactiveColor,
        ),
      ),
    );
  }
}
