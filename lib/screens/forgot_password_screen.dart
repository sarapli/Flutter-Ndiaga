import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                            'Forgot password',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Please enter your phone number below to receive\nyour OTP number.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: kMutedTextColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const PhoneField(label: 'Phone number'),
                          const Spacer(),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).pushNamed(AppRoutes.otp);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Send OTP',
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
