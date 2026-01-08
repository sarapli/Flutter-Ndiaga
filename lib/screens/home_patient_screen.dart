import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';

class HomePatientScreen extends StatelessWidget {
  const HomePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('DoctorPoint', style: TextStyle(color: kTextColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: kTextColor),
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: const Color(0xFFB6BACC),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed(AppRoutes.notifications);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(AppRoutes.search);
          } else if (index == 3) {
            Navigator.of(context).pushNamed(AppRoutes.appointments);
          } else if (index == 4) {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('asset/Logo_maquette.png', height: 28, width: 28),
            activeIcon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE7F3F1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset('asset/Logo_maquette.png', height: 24, width: 24),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Appts'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctor, categories, topic...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Specialist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
              const SizedBox(height: 12),
              SizedBox(
                height: 88,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _SpecialistChip(label: 'Cardio', count: 27),
                    _SpecialistChip(label: 'Heart', count: 43),
                    _SpecialistChip(label: 'Dental', count: 19),
                    _SpecialistChip(label: 'Physio', count: 7),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Cardio Issues?',
                subtitle: 'For cardio patient here can easily contact with doctor. Can chat & live chat.',
                priceTag: '\$100',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Top doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
                  Text('View all', style: TextStyle(fontSize: 13, color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    return _DoctorCard(
                      name: 'Dr. Mahmud N',
                      role: 'Heart Sergon',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorsList),
                    );
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

class _SpecialistChip extends StatelessWidget {
  final String label;
  final int count;
  const _SpecialistChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorsList),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
              const SizedBox(height: 6),
              Text('$count Doctors', style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceTag;
  const _InfoCard({required this.title, required this.subtitle, required this.priceTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0,8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE7F3F1), borderRadius: BorderRadius.circular(8)),
                child: Text(priceTag, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4, color: kMutedTextColor)),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onTap;
  const _DoctorCard({required this.name, required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0,8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: ColoredBox(color: Color(0xFFE9EBF2)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. Mahmud N', style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
                  SizedBox(height: 4),
                  Text('Heart Sergon', style: TextStyle(fontSize: 12, color: kMutedTextColor)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
