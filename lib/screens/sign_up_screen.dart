import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscure = true;
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _doSignUp() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
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
                    label: 'Name',
                    hint: 'Enter your full name',
                    prefix: Icons.person_outline,
                    controller: _name,
                  ),
                  const SizedBox(height: 20),
                  PhoneField(controller: _phone),
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
                      onPressed: _loading ? null : _doSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loading ? 'Please wait...' : 'Create account',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: BottomQuestionLink(
                      question: 'Already have an account? ',
                      action: 'Sign in',
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.signIn),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const OrDivider(label: 'Or Sign up with'),
                  const SizedBox(height: 18),
                  const SocialRow(),
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
