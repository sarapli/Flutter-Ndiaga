import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();

  final List<_DoctorItem> _all = const [
    _DoctorItem(name: 'Dr. Mahmud Nik Hasan', subtitle: 'Cardiologist - Dhaka Medical College Hospital', rating: 4.9, reviews: 37),
    _DoctorItem(name: 'Dr. Winston McCaffrey', subtitle: 'Heart Sergon - Khulna Medical College Hospital', rating: 4.8, reviews: 25),
    _DoctorItem(name: 'Dr. Brycen Bradford', subtitle: 'Therapist - Khulna Medical City Hospital', rating: 4.7, reviews: 42),
    _DoctorItem(name: 'Dr. Tierra Riley', subtitle: 'Heart Sergon - Akij Medical Hospital, Dhaka', rating: 4.6, reviews: 31),
    _DoctorItem(name: 'Dr. Ashley Wentworth', subtitle: 'Heart Sergon - Dhaka Medical College Hospital', rating: 4.5, reviews: 12),
  ];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _all
        .where((d) => d.name.toLowerCase().contains(_query.text.toLowerCase()))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search', style: TextStyle(color: kTextColor)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Dr | Specialist | Hospital',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F8FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final d = list[i];
                return _DoctorTile(item: d);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomBar(index: 2),
    );
  }
}

class _DoctorItem {
  final String name;
  final String subtitle;
  final double rating;
  final int reviews;
  const _DoctorItem({required this.name, required this.subtitle, required this.rating, required this.reviews});
}

class _DoctorTile extends StatelessWidget {
  final _DoctorItem item;
  const _DoctorTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorDetail),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0,6))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'doctor-hero',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const ColoredBox(color: Color(0xFFE9EBF2), child: SizedBox(width: 66, height: 66)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF9130), size: 16),
                      const SizedBox(width: 4),
                      Text('${item.rating} ( ${item.reviews} Reviews)', style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  const _BottomBar({required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: const Color(0xFFB6BACC),
      currentIndex: index,
      onTap: (i) {
        if (i == 0) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.homePatient);
        } else if (i == 1) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.notifications);
        } else if (i == 2) {
        } else if (i == 3) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.appointments);
        } else if (i == 4) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Appts'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}
