import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../session.dart';
import '../models/appointment.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  String? period = 'Morning';
  String? time;
  String? type; // 'voice' | 'message' | 'video'

  static const timesMorning = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM'];
  static const timesEvening = ['05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM'];

  List<String> get slots => period == 'Morning' ? timesMorning : timesEvening;

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
        title: const Text('Appointment', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('10 June, Monday', style: TextStyle(color: kTextColor)),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Morning'),
                  selected: period == 'Morning',
                  onSelected: (_) => setState(() { period = 'Morning'; time = null; }),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Evening'),
                  selected: period == 'Evening',
                  onSelected: (_) => setState(() { period = 'Evening'; time = null; }),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((t) => ChoiceChip(
                label: Text(t),
                selected: time == t,
                onSelected: (_) => setState(() => time = t),
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Fees information', style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
            const SizedBox(height: 10),
            _FeeRow(
              icon: Icons.call,
              label: 'Voice call',
              price: '\$10',
              selected: type == 'voice',
              subtitle: 'Can make a voice call with doctor.',
              onTap: () => setState(() => type = 'voice'),
            ),
            _FeeRow(
              icon: Icons.message_outlined,
              label: 'Messaging',
              price: '\$5',
              selected: type == 'message',
              subtitle: 'Can messaging with doctor.',
              accentColor: const Color(0xFFFFE3CC),
              onTap: () => setState(() => type = 'message'),
            ),
            _FeeRow(
              icon: Icons.videocam_outlined,
              label: 'Video call',
              price: '\$20',
              selected: type == 'video',
              subtitle: 'Can make a video call with doctor.',
              onTap: () => setState(() => type = 'video'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: time == null || type == null
                    ? null
                    : () {
                        appSession.setAppointment(
                          AppointmentSelection(period: period!, time: time!, type: type!),
                        );
                        Navigator.of(context).pushNamed(AppRoutes.patientDetails);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _FeeRow({
    required this.icon,
    required this.label,
    required this.price,
    required this.subtitle,
    this.selected = false,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = selected
        ? (accentColor ?? const Color(0xFFE7F3F1))
        : const Color(0xFFF7F8FB);
    final BorderSide side = BorderSide(
      color: selected ? kPrimaryColor : const Color(0x00000000),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.fromBorderSide(side),
        ),
        child: Row(
          children: [
            Icon(icon, color: kTextColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                ],
              ),
            ),
            Text(price, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
