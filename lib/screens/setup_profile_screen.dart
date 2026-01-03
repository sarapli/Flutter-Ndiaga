import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';
import '../session.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  String? gender;
  DateTime? dob;
  final TextEditingController _address = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

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
        title: const Text('Set up your profile', style: TextStyle(color: kTextColor)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWideLayout(context) ? 560 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Update  your profile to connect your doctor with better impression.',
                    style: TextStyle(fontSize: 14, height: 1.4, color: kMutedTextColor),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(radius: 44, backgroundColor: Color(0xFFF0F2F9)),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Gender
                  const Text('Gender', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kTextColor)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: gender,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => gender = v),
                    decoration: const InputDecoration(
                      hintText: 'Select your gender',
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDividerColor)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDividerColor)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // DOB
                  const Text('Date of birth', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kTextColor)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final res = await showDatePicker(
                        context: context,
                        initialDate: DateTime(now.year - 20, now.month, now.day),
                        firstDate: DateTime(1900),
                        lastDate: now,
                      );
                      if (res != null) setState(() => dob = res);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: kDividerColor)),
                      ),
                      child: Text(
                        dob == null ? 'Type of your birth date' : '${dob!.day}/${dob!.month}/${dob!.year}',
                        style: const TextStyle(color: Color(0xFFB6BACC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Address
                  const AuthField(label: 'Address', hint: 'Enter your address', prefix: Icons.place_outlined),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final route = appSession.role == UserRole.doctor
                            ? AppRoutes.homeDoctor
                            : AppRoutes.homePatient;
                        Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
