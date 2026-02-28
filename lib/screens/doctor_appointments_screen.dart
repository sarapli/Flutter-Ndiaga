import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_style.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My patients appointments', style: TextStyle(color: kTextColor)),
      ),
      body: user == null
          ? const Center(
              child: Text('Please sign in to see your appointments', style: TextStyle(color: kMutedTextColor)),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load appointments', style: TextStyle(color: kMutedTextColor)));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No appointments yet', style: TextStyle(color: kMutedTextColor)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final patient = (data['patientName'] as String?) ?? 'Patient';
                    final type = (data['type'] as String?) ?? 'message';
                    final time = (data['time'] as String?) ?? '';
                    final status = (data['status'] as String?) ?? 'booked';

                    final baseCard = _DoctorApptCard(
                      patient: patient,
                      type: type,
                      time: time,
                      status: status,
                    );

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.94, end: 1.0),
                      duration: Duration(milliseconds: 260 + index * 40),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        final dy = (1.0 - scale) * 24;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX((1.0 - scale) * 0.14)
                              ..rotateY((1.0 - scale) * -0.10),
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: baseCard,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _DoctorApptCard extends StatelessWidget {
  final String patient;
  final String type; // message | voice | video
  final String time;
  final String status;

  const _DoctorApptCard({
    required this.patient,
    required this.type,
    required this.time,
    required this.status,
  });

  IconData get _icon {
    if (type == 'voice') return Icons.call;
    if (type == 'video') return Icons.videocam_outlined;
    return Icons.message_outlined;
  }

  Color get _typeColor {
    switch (type) {
      case 'voice':
        return const Color(0xFF10B981);
      case 'video':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFFFF9130);
    }
  }

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'booked':
        return const Color(0xFF1CA796);
      case 'in progress':
        return const Color(0xFFFFA000);
      case 'decline':
      case 'canceled':
        return const Color(0xFFE53935);
      default:
        return kMutedTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  _typeColor.withValues(alpha: 0.18),
                  _typeColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(_icon, color: _typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patient,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor),
                    ),
                    Text(
                      status,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(_icon, color: _typeColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(fontSize: 12, color: _typeColor, fontWeight: FontWeight.w600),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: kMutedTextColor)),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 12, color: kMutedTextColor),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
