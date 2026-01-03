import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../session.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWideLayout(context) ? 560 : double.infinity),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your role',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: kTextColor),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you signing up as a patient or a doctor?',
                    style: TextStyle(fontSize: 14, height: 1.4, color: kMutedTextColor),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appSession.setRole(UserRole.patient);
                        Navigator.of(context).pushReplacementNamed(AppRoutes.setupProfile);
                      },
                      icon: const Icon(Icons.person_outline),
                      label: const Text('I\'m a patient'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        appSession.setRole(UserRole.doctor);
                        Navigator.of(context).pushReplacementNamed(AppRoutes.doctorSpecialty);
                      },
                      icon: const Icon(Icons.local_hospital_outlined),
                      label: const Text('I\'m a doctor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: kDividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
