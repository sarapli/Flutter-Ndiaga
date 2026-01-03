import 'package:flutter/material.dart';

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, i) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            color: const Color(0xFFF7F8FB),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorDetail),
              leading: const CircleAvatar(backgroundColor: Color(0xFFE9EBF2)),
              title: Text('Dr. Mahmud Nik Hasan', style: const TextStyle(color: kTextColor)),
              subtitle: const Text('Cardiologist - Dhaka Medical College Hospital',
                  style: TextStyle(fontSize: 12, color: kMutedTextColor)),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
