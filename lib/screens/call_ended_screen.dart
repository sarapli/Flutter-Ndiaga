import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_style.dart';
import '../app_routes.dart';

class CallEndedScreen extends StatelessWidget {
  const CallEndedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? 'Dr. Mahmud Nik';
    final duration = args?['duration'] as String? ?? '25:37';
    final doctorId = args?['doctorId'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _loadDoctor(doctorId),
              builder: (context, snapshot) {
                String? doctorAvatarAsset;
                String? doctorPhotoUrl;

                if (snapshot.hasData && snapshot.data!.data() != null) {
                  final data = snapshot.data!.data()!;
                  doctorAvatarAsset = data['avatarAsset'] as String?;
                  doctorPhotoUrl = data['photoUrl'] as String?;
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Call ended', style: TextStyle(color: kTextColor)),
                    const SizedBox(height: 6),
                    Text(
                      duration,
                      style: const TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildDoctorAvatar(
                        avatarAsset: doctorAvatarAsset,
                        photoUrl: doctorPhotoUrl,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      doctor,
                      style: const TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.writeReview, arguments: {'doctor': doctor, 'doctorId': doctorId}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Write a review'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryColor,
                          side: const BorderSide(color: kDividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Go to dashboard'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Charge le document Firestore du docteur si son ID est connu.
Stream<DocumentSnapshot<Map<String, dynamic>>> _loadDoctor(String? doctorId) {
  final db = FirebaseFirestore.instance;
  if (doctorId == null) {
    // renvoyer un snapshot vide
    return Stream.fromFuture(db.collection('users').doc('_none_').get());
  }
  return db.collection('users').doc(doctorId).snapshots();
}

// Construit l'avatar du docteur à partir de l'avatarAsset utilisée côté patient
// (fallback sur photoUrl ou sur l'avatar par défaut Profile.png).
Widget _buildDoctorAvatar({String? avatarAsset, String? photoUrl}) {
  if (avatarAsset != null && avatarAsset.isNotEmpty) {
    return Image.asset(
      avatarAsset,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
    );
  }
  if (photoUrl != null && photoUrl.isNotEmpty) {
    return Image.network(
      photoUrl,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
    );
  }
  return Image.asset(
    'asset/Profile.png',
    width: 96,
    height: 96,
    fit: BoxFit.cover,
  );
}
