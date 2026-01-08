import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../session.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = ModalRoute.of(context)?.settings.arguments as String?;

    Widget buildStatic() {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Doctor', style: TextStyle(color: kTextColor)),
        ),
        body: const Center(child: Text('Doctor information not available')), 
      );
    }

    if (doctorId == null) {
      return buildStatic();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(doctorId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Doctor', style: TextStyle(color: kTextColor));
            }
            final data = snapshot.data!.data()!;
            final name = (data['name'] as String?) ?? 'Doctor';
            return Text(name, style: const TextStyle(color: kTextColor));
          },
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('favouriteDoctors')
                  .doc('${FirebaseAuth.instance.currentUser!.uid}_$doctorId')
                  .snapshots(),
              builder: (context, favSnap) {
                final isFav = favSnap.hasData && favSnap.data!.exists;
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? kPrimaryColor : const Color(0xFF9CA3B7),
                  ),
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    final favRef = FirebaseFirestore.instance
                        .collection('favouriteDoctors')
                        .doc('${user.uid}_$doctorId');
                    if (isFav) {
                      await favRef.delete();
                    } else {
                      String dname = 'Doctor';
                      try {
                        final userDoc = await FirebaseFirestore.instance.collection('users').doc(doctorId).get();
                        dname = (userDoc.data()?['name'] as String?) ?? dname;
                      } catch (_) {}
                      await favRef.set({
                        'patientId': user.uid,
                        'doctorId': doctorId,
                        'doctorName': dname,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(doctorId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Doctor not found'));
          }
          final data = snapshot.data!.data()!;
          final name = (data['name'] as String?) ?? 'Doctor';
          final specialty = (data['specialtyLabel'] as String?) ??
              (data['specialtyId'] as String?) ?? 'Specialist';
          final hospital = (data['hospital'] as String?) ?? '';
          final about = (data['about'] as String?) ??
              'No description provided for this doctor yet.';
          final patients = (data['patientsCount'] as num?)?.toString() ?? '1000+';
          final experienceYears = (data['experienceYears'] as num?)?.toString() ?? '5';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'doctor-hero',
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EBF2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hospital.isNotEmpty ? '$specialty - $hospital' : specialty,
                  style: const TextStyle(color: kMutedTextColor),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Stat(label: 'Patients', value: '$patients+'),
                    const SizedBox(width: 12),
                    _Stat(label: 'Experiences', value: '$experienceYears Years'),
                  ],
                ),
                const SizedBox(height: 22),
                const Text('About doctor',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
                const SizedBox(height: 8),
                Text(
                  about,
                  style: const TextStyle(fontSize: 13, height: 1.45, color: kMutedTextColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      appSession.setDoctor(doctorId, name);
                      Navigator.of(context).pushNamed(AppRoutes.appointment);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Book appointment',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F3F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: kTextColor)),
          ],
        ),
      ),
    );
  }
}
