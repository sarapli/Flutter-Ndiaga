import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_style.dart';
import '../app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'doctor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load doctors'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No doctors found'));
                }

                final query = _query.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? docs
                    : docs.where((d) {
                        final data = d.data();
                        final name = (data['name'] as String?) ?? '';
                        return name.toLowerCase().contains(query);
                      }).toList(growable: false);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No doctors match your search'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data();
                    final name = (data['name'] as String?) ?? 'Doctor';
                    final specialty = (data['specialtyLabel'] as String?) ??
                        (data['specialtyId'] as String?) ??
                        'Specialist';
                    final hospital = (data['hospital'] as String?) ?? '';
                    final subtitle = hospital.isEmpty
                        ? specialty
                        : '$specialty - $hospital';
                    final rating = (data['rating'] as num?)?.toDouble() ?? 4.8;
                    final reviews = (data['reviews'] as num?)?.toInt() ?? 25;
                    final avatarAsset = data['avatarAsset'] as String?;

                    return _DoctorTile(
                      doctorId: doc.id,
                      name: name,
                      subtitle: subtitle,
                      rating: rating,
                      reviews: reviews,
                      avatarAsset: avatarAsset,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomBar(index: 2),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final String doctorId;
  final String name;
  final String subtitle;
  final double rating;
  final int reviews;
  final String? avatarAsset;

  const _DoctorTile({
    required this.doctorId,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviews,
    this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorDetail, arguments: doctorId),
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
                child: avatarAsset == null || avatarAsset!.isEmpty
                    ? const ColoredBox(
                        color: Color(0xFFE9EBF2),
                        child: SizedBox(width: 66, height: 66),
                      )
                    : Image.asset(
                        avatarAsset!,
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                      ),
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
                      Text('$rating ( $reviews Reviews)', style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
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
