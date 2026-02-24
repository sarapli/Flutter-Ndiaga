import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../app_style.dart';

class HospitalDashboardScreen extends StatelessWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: kTextColor)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Patients',
                    icon: Icons.people_outline,
                    stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'patient').snapshots(),
                    countFromSnapshot: (s) => s.size,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Doctors',
                    icon: Icons.medical_information_outlined,
                    stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').snapshots(),
                    countFromSnapshot: (s) => s.size,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Appointments',
                    icon: Icons.event_note_outlined,
                    stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
                    countFromSnapshot: (s) => s.size,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Specialties',
                    icon: Icons.category_outlined,
                    stream: FirebaseFirestore.instance.collection('specialties').snapshots(),
                    countFromSnapshot: (s) => s.size,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Recent activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('appointments').orderBy('createdAt', descending: true).limit(10).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return const Text('Failed to load activity', style: TextStyle(color: kMutedTextColor));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('No recent appointments', style: TextStyle(color: kMutedTextColor));
                }
                return Column(
                  children: [
                    for (final d in docs) ...[
                      _ActivityTile(data: d.data()),
                      const SizedBox(height: 10),
                    ]
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final int Function(QuerySnapshot<Map<String, dynamic>> snapshot) countFromSnapshot;

  const _StatCard({required this.title, required this.icon, required this.stream, required this.countFromSnapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.hasData ? countFromSnapshot(snapshot.data!) : 0;
          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFE7F3F1), shape: BoxShape.circle),
                child: Icon(icon, color: kPrimaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: kMutedTextColor, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('$count', style: const TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ActivityTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final patient = (data['patientName'] as String?) ?? 'Patient';
    final doctor = (data['doctorName'] as String?) ?? 'Doctor';
    final status = (data['status'] as String?) ?? 'booked';
    final time = (data['time'] as String?) ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFE9EBF2), child: Icon(Icons.event_note_outlined, color: kTextColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$patient → $doctor', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Status: $status${time.isNotEmpty ? ' • $time' : ''}', style: const TextStyle(color: kMutedTextColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
