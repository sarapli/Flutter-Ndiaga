import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../session.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

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
        title: const Text('Dr. Mahmud Nik', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
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
            const Text('Cardiologist - Dhaka Medical College Hospital',
                style: TextStyle(color: kMutedTextColor)),
            const SizedBox(height: 16),
            Row(
              children: const [
                _Stat(label: 'Patients', value: '1000+'),
                SizedBox(width: 12),
                _Stat(label: 'Experiences', value: '5 Years'),
              ],
            ),
            const SizedBox(height: 22),
            const Text('About doctor', style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 8),
            const Text(
              'Dr. Mahmud Nik is the top most Cardiologist specialist... Available for private consultation.',
              style: TextStyle(fontSize: 13, height: 1.45, color: kMutedTextColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  appSession.setDoctor('Dr. Mahmud Nik');
                  Navigator.of(context).pushNamed(AppRoutes.appointment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Book appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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
