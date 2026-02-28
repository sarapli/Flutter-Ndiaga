import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _selectedAvatar;

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
                    child: SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _avatarTile('asset/Imagedoctor1.png'),
                          _avatarTile('asset/imagedoctor2.png'),
                          _avatarTile('asset/imagedoctor3.png'),
                          _avatarTile('asset/imagedoctor4.png'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final route = appSession.role == UserRole.doctor
                            ? AppRoutes.shellDoctor
                            : AppRoutes.homePatient;

                        if (appSession.role == UserRole.doctor) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null && _selectedAvatar != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({'avatarAsset': _selectedAvatar}, SetOptions(merge: true));
                          }
                        }
                        nav.pushNamedAndRemoveUntil(route, (r) => false);
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

  Widget _avatarTile(String asset) {
    final selected = _selectedAvatar == asset;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = asset;
        });
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kPrimaryColor : const Color(0xFFE0E3EE), width: selected ? 2 : 1),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6)),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

