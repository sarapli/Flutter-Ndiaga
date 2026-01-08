import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class MessageEndedScreen extends StatelessWidget {
  const MessageEndedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? 'Dr. Mahmud Nik';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Time end for messaging appointment', style: TextStyle(color: kTextColor)),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const ColoredBox(
                    color: Color(0xFFE9EBF2),
                    child: SizedBox(width: 96, height: 96),
                  ),
                ),
                const SizedBox(height: 14),
                Text(doctor, style: const TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.writeReview, arguments: {'doctor': doctor}),
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
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kDividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Go to dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
