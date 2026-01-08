import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_routes.dart';
import '../app_style.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

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
        title: const Text('Doctors', style: TextStyle(color: kTextColor)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final name = (data['name'] as String?) ?? 'Doctor';
              final hospital = (data['hospital'] as String?) ?? '';
              final specialtyLabel = (data['specialtyLabel'] as String?) ??
                  (data['specialtyId'] as String?) ?? '';
              final subtitle = specialtyLabel.isNotEmpty && hospital.isNotEmpty
                  ? '$specialtyLabel - $hospital'
                  : (specialtyLabel.isNotEmpty ? specialtyLabel : hospital);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                color: const Color(0xFFF7F8FB),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.doctorDetail, arguments: doc.id),
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE9EBF2)),
                  title: Text(name, style: const TextStyle(color: kTextColor)),
                  subtitle: Text(
                    subtitle.isEmpty ? 'Doctor' : subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: kMutedTextColor),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
