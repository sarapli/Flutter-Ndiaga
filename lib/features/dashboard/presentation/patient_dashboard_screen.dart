import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app_routes.dart';
import '../../../app_style.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late final PageController _topDoctorsController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _topDoctorsController = PageController(viewportFraction: 0.72);
    _topDoctorsController.addListener(() {
      setState(() {
        _currentPage = _topDoctorsController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _topDoctorsController.dispose();
    super.dispose();
  }

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
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header maquette: avatar + texte + calendrier
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    return Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage('asset/Profile.png'),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kTextColor,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Find your suitable doctor here',
                                style: TextStyle(fontSize: 13, color: kMutedTextColor),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F3F1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.calendar_month_outlined, color: kPrimaryColor, size: 22),
                            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
                          ),
                        ),
                      ],
                    );
                  }

                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final name = (data != null && data['name'] is String && (data['name'] as String).trim().isNotEmpty)
                          ? (data['name'] as String).trim()
                          : 'Patient';

                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage('asset/Profile.png'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Find your suitable doctor here',
                                  style: TextStyle(fontSize: 13, color: kMutedTextColor),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F3F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month_outlined, color: kPrimaryColor, size: 22),
                              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctor, catagories, topic . . .',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Specialist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const _StaticSpecialistCard(
                      title: 'Cardio Specialist',
                      subtitle: '27 Doctors',
                      background: Color(0xFF0EBE7F),
                      icon: Icons.favorite_outline,
                    ),
                    const _StaticSpecialistCard(
                      title: 'Heart Issue',
                      subtitle: '43 Doctors',
                      background: Color(0xFF3D8BFF),
                      icon: Icons.health_and_safety_outlined,
                    ),
                    const _StaticSpecialistCard(
                      title: 'Dental Care',
                      subtitle: '19 Doctors',
                      background: Color(0xFFFFA726),
                      icon: Icons.medical_services_outlined,
                    ),
                    const _StaticSpecialistCard(
                      title: 'Physio Therapy',
                      subtitle: '07 Doctors',
                      background: Color(0xFF8E5CF8),
                      icon: Icons.accessibility_new_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _InfoCard(
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
                height: 200,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'doctor')
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load doctors'));
                    }
                    final allDocs = snapshot.data?.docs ?? [];
                    final docs = allDocs
                        .where((d) {
                          final data = d.data();
                          final name = (data['name'] as String?) ?? '';
                          return name != 'Version 4.0';
                        })
                        .toList();

                    if (docs.isEmpty) {
                      return const Center(child: Text('No top doctors'));
                    }

                    return PageView.builder(
                      controller: _topDoctorsController,
                      itemCount: docs.length,
                      padEnds: false,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final name = (data['name'] as String?) ?? 'Doctor';
                        final specialty = (data['specialtyLabel'] as String?) ??
                            (data['specialtyId'] as String?) ?? 'Specialist';
                        final avatarAsset = (data['avatarAsset'] as String?) ?? _fallbackDoctorAsset(index);

                        final distance = (index - _currentPage).abs();
                        final scale = 1.0 - (distance * 0.18).clamp(0.0, 0.36);
                        final translationY = 12 * distance;

                        return Transform.translate(
                          offset: Offset(0, translationY),
                          child: Transform.scale(
                            scale: scale,
                            child: _DoctorCard(
                              name: name,
                              specialty: specialty,
                              avatarAsset: avatarAsset,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.doctorDetail, arguments: doc.id),
                            ),
                          ),
                        );
                      },
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
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 8))],
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
  final String specialty;
  final String avatarAsset;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.name,
    required this.specialty,
    required this.avatarAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 4),
                  Text(specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

String _fallbackDoctorAsset(int index) {
  const assets = [
    'asset/Imagedoctor1.png',
    'asset/imagedoctor2.png',
    'asset/imagedoctor3.png',
    'asset/imagedoctor4.png',
  ];
  return assets[index % assets.length];
}

class _StaticSpecialistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color background;
  final IconData icon;

  const _StaticSpecialistCard({
    required this.title,
    required this.subtitle,
    required this.background,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
