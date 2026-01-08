import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';
import '../app_routes.dart';

class FavouriteDoctorsScreen extends StatefulWidget {
  const FavouriteDoctorsScreen({super.key});

  @override
  State<FavouriteDoctorsScreen> createState() => _FavouriteDoctorsScreenState();
}

class _FavouriteDoctorsScreenState extends State<FavouriteDoctorsScreen> {
  Future<void> _removeFavourite(String favDocId) async {
    try {
      await FirebaseFirestore.instance.collection('favouriteDoctors').doc(favDocId).delete();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Favourite doctors', style: TextStyle(color: kTextColor)),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view favourites', style: TextStyle(color: kMutedTextColor)))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('favouriteDoctors')
                  .where('patientId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No favourite doctors yet', style: TextStyle(color: kMutedTextColor)),
                  );
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final doctorName = (data['doctorName'] as String?) ?? 'Doctor';
                    final doctorId = (data['doctorId'] as String?) ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))]),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFE9EBF2)),
                        title: Text(doctorName, style: const TextStyle(color: kTextColor)),
                        subtitle: Text('Favourite doctor', style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: kPrimaryColor),
                          onPressed: () => _removeFavourite(doc.id),
                        ),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.doctorDetail,
                          arguments: doctorId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
