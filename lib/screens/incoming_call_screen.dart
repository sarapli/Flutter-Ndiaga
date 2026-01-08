import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? 'Dr. Mahmud Nik';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Spacer(),
            const Text('Incoming call', style: TextStyle(color: kTextColor)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE9EBF2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const ColoredBox(
                  color: Color(0xFFE9EBF2),
                  child: SizedBox(width: 104, height: 104),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(doctor, style: const TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CallAction(
                    label: 'Decline',
                    color: const Color(0xFFE85151),
                    icon: Icons.call_end_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _CallAction(
                    label: 'Accept',
                    color: kPrimaryColor,
                    icon: Icons.call,
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.voiceCall, arguments: {'doctor': doctor}),
                  ),
                  _CallAction(
                    label: 'Message',
                    color: const Color(0xFFFF9130),
                    icon: Icons.message_outlined,
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.chat, arguments: {'doctor': doctor}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _CallAction({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: kTextColor)),
      ],
    );
  }
}
