import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
                        'OTP',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Put the OTP number below sent to your number\n+254 5684 586 942',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: kMutedTextColor,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const OtpBox(text: '5'),
                          const OtpBox(text: '3'),
                          const OtpBox(text: '|', active: true),
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppRoutes.resetPassword),
                            child: const OtpBox(text: ''),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Center(
                        child: Text(
                          'Code send in 0:29',
                          style: TextStyle(fontSize: 13, color: Color(0xFFB6BACC)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'Resend code',
                          style: TextStyle(fontSize: 13, color: kPrimaryColor),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Keypad(),
                      const SizedBox(height: 24),
                    ],
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
