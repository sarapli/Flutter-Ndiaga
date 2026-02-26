import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_routes.dart';
import '../app_style.dart';

class HomePatientScreen extends StatefulWidget {
  const HomePatientScreen({super.key});

  @override
  State<HomePatientScreen> createState() => _HomePatientScreenState();
}

class _HomePatientScreenState extends State<HomePatientScreen> {
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
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Logo item (sélectionné par défaut sur l'écran home patient)
                Container(
                  width: 52,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F3F1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Image.asset(
                    'asset/Logo_maquette.png',
                    fit: BoxFit.contain,
                  ),
                ),
                _ProtoNavIcon(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                _ProtoNavIcon(
                  icon: Icons.search_rounded,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
                ),
                _ProtoNavIcon(
                  icon: Icons.list_alt_outlined,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
                ),
                _ProtoNavIcon(
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header style maquette (avatar + texte + bouton calendrier)
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
                            onPressed: () {},
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
                              onPressed: () {},
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
                height: 88,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('specialties')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load specialties'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No specialties'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final label = (data['shortName'] as String?) ??
                            (data['name'] as String?) ?? 'Specialist';
                        final count = (data['doctorsCount'] as num?)?.toInt() ?? 0;
                        return _SpecialistChip(label: label, count: count);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const _InfoCard(
                title: 'Cardio Issues?',
                subtitle: 'For cardio patient here can easily contact with doctor. Can chat & live chat.',
                priceTag: '100',
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
                    final docs = snapshot.data?.docs ?? [];
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
                        final role = (data['specialtyLabel'] as String?) ??
                            (data['specialtyId'] as String?) ?? 'Specialist';
                        final avatarAsset = (data['avatarAsset'] as String?) ?? _fallbackDoctorAsset(index);

                        final distance = (index - _currentPage).abs();
                        final scale = 1.0 - (distance * 0.15).clamp(0.0, 0.30);
                        final translationY = 16 * distance;
                        final rotationY = (index - _currentPage) * 0.35;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..translate(0.0, translationY, distance * 40)
                            ..rotateY(rotationY),
                          child: Transform.scale(
                            scale: scale,
                            child: _DoctorCard(
                              name: name,
                              role: role,
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

class _ProtoNavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ProtoNavIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 24,
          color: const Color(0xFF8A8FA3), // gris comme sur le prototype
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
  final String avatarAsset;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.name,
    required this.role,
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
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0,8))],
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
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kMutedTextColor),
                  ),
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
