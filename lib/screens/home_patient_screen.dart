import 'dart:async';

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
  late final ScrollController _topDoctorsScrollController;
  Timer? _topDoctorsTimer;

  @override
  void initState() {
    super.initState();
    _topDoctorsScrollController = ScrollController();
    _topDoctorsTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_topDoctorsScrollController.hasClients) return;
      final maxScroll = _topDoctorsScrollController.position.maxScrollExtent;
      final current = _topDoctorsScrollController.offset;
      final next = current + 1;
      if (next >= maxScroll) {
        _topDoctorsScrollController.jumpTo(0);
      } else {
        _topDoctorsScrollController.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _topDoctorsTimer?.cancel();
    _topDoctorsScrollController.dispose();
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
              const SizedBox(height: 8),
              SizedBox(
                height: 112,
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
                      const fallback = [
                        {'label': 'Cardio Specialist', 'count': 27},
                        {'label': 'Heart Issue', 'count': 43},
                        {'label': 'Dental Care', 'count': 19},
                        {'label': 'Physio Therapy', 'count': 7},
                      ];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: fallback.length,
                        itemBuilder: (context, index) {
                          final item = fallback[index];
                          const colors = [
                            Color(0xFF0F9D58),
                            Color(0xFF3B82F6),
                            Color(0xFFFFA000),
                            Color(0xFF8B5CF6),
                          ];
                          const icons = [
                            Icons.favorite_border,
                            Icons.monitor_heart_outlined,
                            Icons.medical_services_outlined,
                            Icons.healing_outlined,
                          ];
                          final bgColor = colors[index % colors.length];
                          final icon = icons[index % icons.length];
                          return _SpecialistChip(
                            label: item['label'] as String,
                            count: item['count'] as int,
                            backgroundColor: bgColor,
                            icon: icon,
                          );
                        },
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final label = (data['shortName'] as String?) ??
                            (data['name'] as String?) ?? 'Specialist';
                        final count = (data['doctorsCount'] as num?)?.toInt() ?? 0;
                        const colors = [
                          Color(0xFF0F9D58),
                          Color(0xFF3B82F6),
                          Color(0xFFFFA000),
                          Color(0xFF8B5CF6),
                        ];
                        const icons = [
                          Icons.favorite_border,
                          Icons.monitor_heart_outlined,
                          Icons.medical_services_outlined,
                          Icons.healing_outlined,
                        ];
                        final bgColor = colors[index % colors.length];
                        final icon = icons[index % icons.length];
                        return _SpecialistChip(
                          label: label,
                          count: count,
                          backgroundColor: bgColor,
                          icon: icon,
                        );
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
                height: 190,
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
                    final docs = allDocs.where((d) {
                      final data = d.data();
                      final name = (data['name'] as String?) ?? '';
                      return name.trim() != 'Version 4.0';
                    }).toList(growable: false);
                    if (docs.isEmpty) {
                      return const Center(child: Text('No top doctors'));
                    }
                    return ListView.builder(
                      controller: _topDoctorsScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final name = (data['name'] as String?) ?? 'Doctor';
                        final role = (data['specialtyLabel'] as String?) ??
                            (data['specialtyId'] as String?) ?? 'Specialist';

                        final existingAvatar = data['avatarAsset'] as String?;
                        final avatarAsset = existingAvatar ?? _fallbackDoctorAsset(index);

                        // Si aucun avatar n'est encore enregistré pour ce docteur,
                        // on persiste l'avatar de maquette afin qu'il soit réutilisé
                        // partout (Search, Call Ended, compte docteur, etc.).
                        if (existingAvatar == null || existingAvatar.isEmpty) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(doc.id)
                              .set({'avatarAsset': avatarAsset}, SetOptions(merge: true));
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 150,
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
  final Color backgroundColor;
  final IconData icon;

  const _SpecialistChip({
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorsList),
        child: Container(
          width: 136,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: backgroundColor),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '$count Doctors',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE0F2F1)),
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
