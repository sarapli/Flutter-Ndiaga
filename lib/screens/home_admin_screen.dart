import 'package:flutter/material.dart';

import '../app_style.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: kTextColor,
      ),
      body: const SafeArea(
        child: Center(
          child: Text('Home Admin (à implémenter)'),
        ),
      ),
    );
  }
}
