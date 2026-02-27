import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';

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
                                  'Welcome to your dashboard',
                                  style: TextStyle(color: kMutedTextColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome, Doctor!',
                          style: TextStyle(color: kTextColor, fontSize: 16),
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
