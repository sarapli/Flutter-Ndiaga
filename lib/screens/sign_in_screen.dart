import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
                          .pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  const SocialRow(),
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
