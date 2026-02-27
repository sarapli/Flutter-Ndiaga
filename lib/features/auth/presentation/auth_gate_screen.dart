import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_routes.dart';
import 'auth_providers.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  StreamSubscription<User?>? _sub;

  @override
  void initState() {
    super.initState();

    _sub = ref.read(authRepositoryProvider).authStateChanges().listen((user) {
      if (!mounted) return;
      unawaited(_handleUser(user));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _handleUser(User? user) async {
    if (!mounted) return;

    if (user == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data() ?? const <String, dynamic>{};
      final role = (data['role'] as String?)?.toLowerCase().trim();

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homeAdmin, (_) => false);
        return;
      }

      if (role == 'doctor') {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.shellDoctor, (_) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homePatient, (_) => false);
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homePatient, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
