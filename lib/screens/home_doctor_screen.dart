import 'package:flutter/material.dart';

import '../app_style.dart';

class HomeDoctorScreen extends StatelessWidget {
  const HomeDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Doctor Dashboard', style: TextStyle(color: kTextColor)),
      ),
      body: const Center(
        child: Text('Welcome, Doctor!', style: TextStyle(color: kTextColor)),
      ),
    );
  }
}
