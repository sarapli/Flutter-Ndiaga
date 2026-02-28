import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';
import '../app_routes.dart';

class HomeDoctorScreen extends StatelessWidget {
  const HomeDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Doctor Dashboard', style: TextStyle(color: kTextColor)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: user == null
              ? const Center(
                  child: Text('Welcome, Doctor!', style: TextStyle(color: kTextColor)),
                )
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data();
                    final name = (data != null && data['name'] is String && (data['name'] as String).trim().isNotEmpty)
                        ? (data['name'] as String).trim()
                        : 'Doctor';
                    final avatarAsset = data?['avatarAsset'] as String?;
                    final photoUrl = data?['photoUrl'] as String?;

                    Widget avatar;
                    if (avatarAsset != null && avatarAsset.isNotEmpty) {
                      avatar = Image.asset(avatarAsset, fit: BoxFit.cover);
                    } else if (photoUrl != null && photoUrl.isNotEmpty) {
                      avatar = Image.network(photoUrl, fit: BoxFit.cover);
                    } else {
                      avatar = Image.asset('asset/Profile.png', fit: BoxFit.cover);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: avatar,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Stay close to your patients',
                                  style: TextStyle(color: kMutedTextColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Actions rapides : Messages, Appels, Favoris
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _DoctorQuickAction(
                              icon: Icons.chat_bubble_outline,
                              label: 'Messages',
                              route: AppRoutes.chat,
                            ),
                            _DoctorQuickAction(
                              icon: Icons.call_outlined,
                              label: 'Calls',
                              route: AppRoutes.voiceCall,
                            ),
                            _DoctorQuickAction(
                              icon: Icons.favorite_outline,
                              label: 'Favourites',
                              route: AppRoutes.favouriteDoctors,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        const Text(
                          'Recent patients',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _DoctorPatientsList(doctorId: user.uid),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _DoctorQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DoctorQuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: kTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorPatientsList extends StatelessWidget {
  final String doctorId;

  const _DoctorPatientsList({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load patients'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No patients yet.\nYour upcoming patients will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMutedTextColor),
            ),
          );
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final patientName = (data['patientName'] as String?) ?? 'Patient';
            final type = (data['type'] as String?) ?? 'message';
            final status = (data['status'] as String?) ?? 'Booked';
            final time = (data['time'] as String?) ?? '';

            IconData icon;
            if (type == 'voice') {
              icon = Icons.call;
            } else if (type == 'video') {
              icon = Icons.videocam_outlined;
            } else {
              icon = Icons.message_outlined;
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE9EBF2),
                    child: Icon(icon, color: kPrimaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 12, color: kMutedTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 12, color: kMutedTextColor),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
