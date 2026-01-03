import 'package:flutter/material.dart';

import '../app_style.dart';
import '../session.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appt = appSession.appointment;
    final doctor = appSession.doctorName ?? 'your doctor';
    final action = appt == null
        ? 'contact you'
        : appt.type == 'voice'
            ? 'call you'
            : appt.type == 'video'
                ? 'video call you'
                : 'message you';

    final todayItems = [
      _NotifItem(
        icon: Icons.notifications_active_outlined,
        title: 'Serial reminder',
        text:
            'Your serial is successfully added in appointment list. Serial number is 25. DoctorPoint will notice you before 15 minutes.',
      ),
      _NotifItem(
        icon: Icons.alarm_outlined,
        title: 'Appointment alarm',
        text: 'Your appointment will be start after 15 minutes. Stay with app and take care.',
      ),
      _NotifItem(
        icon: Icons.check_circle_outline,
        title: 'Appointment confirmed',
        text: "Your Appointment with $doctor is confirmed. He will $action at ${appt?.time ?? '11:00 AM'} | 10 June, 2020",
        highlightDoctor: doctor,
      ),
    ];

    final yesterdayItems = [
      _NotifItem(
        icon: Icons.notifications_active_outlined,
        title: 'Serial reminder',
        text:
            'Your serial is successfully added in appointment list. Serial number is 25. DoctorPoint will notice you before 15 minutes.',
      ),
      _NotifItem(
        icon: Icons.alarm_outlined,
        title: 'Appointment alarm',
        text: 'Your appointment will be start after 15 minutes. Stay with app and take care.',
      ),
      _NotifItem(
        icon: Icons.check_circle_outline,
        title: 'Appointment confirmed',
        text: "Your Appointment with $doctor is confirmed. He will $action at ${appt?.time ?? '11:00 AM'} | 10 June, 2020",
        highlightDoctor: doctor,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications', style: TextStyle(color: kTextColor)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          const Text('Today  -  10 June, 2020', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...todayItems.map((e) => _NotifCard(item: e)),
          const SizedBox(height: 16),
          const Text('11 June, 2020', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...yesterdayItems.map((e) => _NotifCard(item: e)),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final String title;
  final String text;
  final String? highlightDoctor;
  const _NotifItem({required this.icon, required this.title, required this.text, this.highlightDoctor});
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final parts = item.highlightDoctor == null ? null : item.text.split(item.highlightDoctor!);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0,6))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFE7F3F1), child: Icon(item.icon, color: kPrimaryColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
                const SizedBox(height: 4),
                if (parts == null)
                  Text(item.text, style: const TextStyle(color: kMutedTextColor, height: 1.4))
                else
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: parts[0], style: const TextStyle(color: kMutedTextColor)),
                      TextSpan(text: item.highlightDoctor!, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
                      TextSpan(text: parts.length > 1 ? parts[1] : '', style: const TextStyle(color: kMutedTextColor)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
