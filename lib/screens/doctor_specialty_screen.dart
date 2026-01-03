import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../session.dart';

class DoctorSpecialtyScreen extends StatelessWidget {
  const DoctorSpecialtyScreen({super.key});

  static const List<String> specialties = <String>[
    'Cardio', 'Heart', 'Dental', 'Physio', 'Dermatology', 'Neurology', 'Pediatrics',
    'Orthopedic', 'ENT', 'General'
  ];

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
        title: const Text('Choose specialty', style: TextStyle(color: kTextColor)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWideLayout(context) ? 560 : double.infinity),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: specialties.map((s) {
                  final bool selected = appSession.specialty == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    selectedColor: const Color(0xFFE7F3F1),
                    onSelected: (_) {
                      appSession.setSpecialty(s);
                      Navigator.of(context).pushReplacementNamed(AppRoutes.setupProfile);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
