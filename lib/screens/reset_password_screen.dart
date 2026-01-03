import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isWideLayout(context) ? 520 : double.infinity),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: BackSquareButton(
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Recovery password',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Enter your new and confirm password to reset\nyour password.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: kMutedTextColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthField(
                            label: 'Password',
                            hint: '••••••••',
                            prefix: Icons.lock_outline,
                            obscureText: _obscure1,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure1 = !_obscure1),
                              icon: Icon(
                                _obscure1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9CA3B7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AuthField(
                            label: 'Confirm password',
                            hint: 'Enter confirm password',
                            prefix: Icons.lock_outline,
                            obscureText: _obscure2,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure2 = !_obscure2),
                              icon: Icon(
                                _obscure2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9CA3B7),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                AppRoutes.signIn,
                                (r) => false,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Reset password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
          },
        ),
      ),
    );
  }
}
