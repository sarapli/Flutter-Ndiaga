import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../session.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? appSession.doctorName ?? 'Dr. Mahmud Nik';
    final type = args?['type'] as String? ?? appSession.appointment?.type ?? 'message';
    final timeRange = args?['timeRange'] as String? ??
        (appSession.appointment != null ? '${appSession.appointment!.time} - 11:00 AM' : '10:00 AM - 11:00 AM');
    final dateLabel = args?['date'] as String? ?? 'Today - 10 June, 2020';

    String fee() {
      switch (type) {
        case 'voice':
          return '\$10';
        case 'video':
          return '\$20';
        default:
          return '\$5';
      }
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
        title: const Text('Online appointments', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Color(0xFFE9EBF2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor)),
                      const SizedBox(height: 4),
                      const Text('Cardiologist - Dhaka Medical College Hospital', style: TextStyle(fontSize: 12, color: kMutedTextColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TypePanel(activeType: type),
            const SizedBox(height: 16),
            const Text('Visit time', style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 6),
            const Text('Morning', style: TextStyle(color: kMutedTextColor)),
            const SizedBox(height: 2),
            Text(dateLabel, style: const TextStyle(color: kMutedTextColor)),
            const SizedBox(height: 6),
            Text(timeRange, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            const Text('Patient information', style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 8),
            _InfoRow(label: 'Name', value: 'Mahmudul Hasan Manik'),
            _InfoRow(label: 'Age', value: '23'),
            _InfoRow(label: 'Phone', value: '+880 1234 886788'),
            const SizedBox(height: 18),
            const Text('Fees information', style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 8),
            const Text('Paid', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
            Text(fee(), style: const TextStyle(color: kMutedTextColor)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.writeReview,
                  arguments: {'doctor': doctor},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Write a review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePanel extends StatelessWidget {
  final String activeType; // voice | message | video
  const _TypePanel({required this.activeType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1CA796),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TypeIcon(icon: Icons.call, active: activeType == 'voice'),
          _TypeIcon(icon: Icons.message_outlined, active: activeType == 'message'),
          _TypeIcon(icon: Icons.videocam_outlined, active: activeType == 'video'),
          _TypeIcon(icon: Icons.alarm, active: false),
        ],
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _TypeIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: active ? Colors.white : const Color(0xFF178F80),
      child: Icon(icon, color: active ? kPrimaryColor : Colors.white),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text('$label  :', style: const TextStyle(color: kMutedTextColor))),
          Expanded(child: Text(value, style: const TextStyle(color: kTextColor))),
        ],
      ),
    );
  }
}
