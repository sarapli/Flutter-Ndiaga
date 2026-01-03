import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscure = true;

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
                  const AuthField(
                    label: 'Email',
                    hint: 'manikstk@gmail.com',
                    prefix: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  const AuthField(
                    label: 'Name',
                    hint: 'Enter your full name',
                    prefix: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  const PhoneField(),
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
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.roleSelection),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
