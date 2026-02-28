import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app_style.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

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
        child: user == null
            ? const Center(child: Text('Please sign in', style: TextStyle(color: kMutedTextColor)))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final name = (data?['name'] as String?) ?? 'Doctor';
                      final specialty = (data?['specialtyLabel'] as String?) ?? (data?['specialtyId'] as String?) ?? '';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BFA6), Color(0xFF0F9BCE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              child: const Icon(Icons.medical_information, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Welcome back', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                                  if (specialty.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(specialty, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _MiniActivityBars(),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CountCard(
                          title: 'My appointments',
                          icon: Icons.event_note_outlined,
                          accentColor: const Color(0xFF4F46E5),
                          stream: FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: user.uid).snapshots(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CountCard(
                          title: 'Upcoming',
                          icon: Icons.schedule,
                          accentColor: const Color(0xFF10B981),
                          stream: FirebaseFirestore.instance
                              .collection('appointments')
                              .where('doctorId', isEqualTo: user.uid)
                              .where('status', isEqualTo: 'booked')
                              .snapshots(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PatientsCard(doctorId: user.uid),
                  const SizedBox(height: 18),
                  const Text('Recent appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: user.uid)
                        .orderBy('createdAt', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError) {
                        return const Text('Failed to load appointments', style: TextStyle(color: kMutedTextColor));
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Text('No appointments yet', style: TextStyle(color: kMutedTextColor));
                      }
                      return Column(
                        children: [
                          for (final d in docs) ...[
                            _ApptTile(data: d.data()),
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

class _CountCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Color accentColor;

  const _CountCard({required this.title, required this.icon, required this.stream, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withValues(alpha: 0.12), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.data?.size ?? 0;
          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: kMutedTextColor, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('$count', style: const TextStyle(color: kTextColor, fontSize: 22, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TinySparkline(color: accentColor),
            ],
          );
        },
      ),
    );
  }
}

class _PatientsCard extends StatelessWidget {
  final String doctorId;
  const _PatientsCard({required this.doctorId});

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
        stream: FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: doctorId).snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          final patientIds = <String>{};
          for (final d in docs) {
            final id = d.data()['patientId'] as String?;
            if (id != null && id.isNotEmpty) patientIds.add(id);
          }

          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFE7F3F1), shape: BoxShape.circle),
                child: const Icon(Icons.people_outline, color: kPrimaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My patients', style: TextStyle(color: kMutedTextColor, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('${patientIds.length}', style: const TextStyle(color: kTextColor, fontSize: 22, fontWeight: FontWeight.w700)),
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

class _MiniActivityBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 42,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _Bar(height: 14, color: Colors.white70),
          _Bar(height: 24, color: Colors.white),
          _Bar(height: 18, color: Colors.white70),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;

  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _TinySparkline extends StatelessWidget {
  final Color color;

  const _TinySparkline({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 26,
      child: CustomPaint(
        painter: _TinySparklinePainter(color),
      ),
    );
  }
}

class _TinySparklinePainter extends CustomPainter {
  final Color color;

  _TinySparklinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    path.lineTo(size.width * 0.75, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ApptTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ApptTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final patient = (data['patientName'] as String?) ?? 'Patient';
    final status = (data['status'] as String?) ?? 'booked';
    final time = (data['time'] as String?) ?? '';
    final type = (data['type'] as String?) ?? 'message';

    IconData icon;
    if (type == 'voice') {
      icon = Icons.call;
    } else if (type == 'video') {
      icon = Icons.videocam_outlined;
    } else {
      icon = Icons.message_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFE9EBF2), child: Icon(icon, color: kTextColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
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
