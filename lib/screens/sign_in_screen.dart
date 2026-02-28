import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscure = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _doSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithEmail(_email.text.trim(), _password.text);
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final db = FirebaseFirestore.instance;
      final ref = db.collection('users').doc(user.uid);
      final snap = await ref.get();
      final data = snap.data() ?? <String, dynamic>{};
      final role = (data['role'] as String?) ?? 'patient';

      _navigateByRole(role);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSocialPostAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc(user.uid);
    final snap = await ref.get();
    final data = snap.data() ?? <String, dynamic>{};
    final role = data['role'] as String?;

    // Si un rôle existe déjà, on respecte ce rôle
    if (role == 'patient' || role == 'doctor') {
      if (!mounted) return;
      if (role == 'patient') {
        final hasMinimalProfile = ((data['name'] as String?)?.isNotEmpty == true) &&
            ((data['phone'] as String?)?.isNotEmpty == true);
        if (!hasMinimalProfile) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.editProfile,
            (r) => false,
            arguments: {'firstTime': true},
          );
        } else {
          _navigateByRole('patient');
        }
      } else {
        // Utilisateur déjà marqué comme docteur (existant) : on le route comme docteur
        _navigateByRole('doctor');
      }
      return;
    }

    // Nouveau compte social sans rôle : on force désormais le rôle patient
    await ref.set({'role': 'patient'}, SetOptions(merge: true));
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.editProfile,
      (r) => false,
      arguments: {'firstTime': true},
    );
  }

  void _navigateByRole(String role) {
    final nav = Navigator.of(context);
    if (role == 'doctor') {
      nav.pushNamedAndRemoveUntil(AppRoutes.shellDoctor, (r) => false);
    } else {
      nav.pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false);
    }
  }

  Future<void> _doGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (user == null) {
        return; // user cancelled popup or sign-in failed silently
      }
      await _handleSocialPostAuth();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doFacebook() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.signInWithFacebook();
      if (user == null) {
        return; // user cancelled login
      }
      await _handleSocialPostAuth();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: authMaxWidthConstraints(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  const Center(
                    child: Image(
                      image: AssetImage('asset/Logo_maquette.png'),
                      width: 180,
                    ),
                  ),
                  const SizedBox(height: 36),
                  AuthField(
                    label: 'Email',
                    hint: 'you@example.com',
                    prefix: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    label: 'Password',
                    hint: 'Enter password',
                    prefix: Icons.lock_outline,
                    obscureText: _obscure,
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9CA3B7),
                      ),
                    ),
                    controller: _password,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _doSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loading ? 'Please wait...' : 'Sign In',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.forgotPassword),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFCBCDD6),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const OrDivider(label: 'Or Sign in\nwith'),
                  const SizedBox(height: 18),
                  SocialRow(
                    onGoogle: _doGoogle,
                    onFacebook: _doFacebook,
                    onInstagram: _doFacebook, // redirect Instagram -> Facebook
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: BottomQuestionLink(
                      question: 'Haven\'t any account? ',
                      action: 'Create account',
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.signUp),
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
