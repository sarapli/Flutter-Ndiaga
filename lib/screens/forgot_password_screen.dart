import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phone = TextEditingController();
  bool _sending = false;
  String _phoneCode = '+254';

  static const List<_CountryDial> _countries = [
    _CountryDial('SN', '+221'),
    _CountryDial('CI', '+225'),
    _CountryDial('ML', '+223'),
    _CountryDial('GN', '+224'),
    _CountryDial('FR', '+33'),
    _CountryDial('GB', '+44'),
    _CountryDial('US', '+1'),
    _CountryDial('NL', '+31'),
    _CountryDial('MA', '+212'),
    _CountryDial('DZ', '+213'),
    _CountryDial('TN', '+216'),
    _CountryDial('NG', '+234'),
    _CountryDial('KE', '+254'),
  ];

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final local = _phone.text.trim();
      final phone = '$_phoneCode$local';
      final verificationId = await AuthService.instance.sendOtp(phone);
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.otp, arguments: {
        'verificationId': verificationId,
        'phone': phone,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.call_outlined, size: 22, color: Color(0xFF9CA3B7)),
                                  SizedBox(width: 12),
                                  Text(
                                    'Phone number',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: kTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8FB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: kDividerColor),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _phoneCode,
                                        isDense: true,
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() => _phoneCode = v);
                                        },
                                        items: [
                                          for (final c in _countries)
                                            DropdownMenuItem(
                                              value: c.dial,
                                              child: Text(
                                                c.dial,
                                                style: const TextStyle(color: kTextColor),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _phone,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your phone number',
                                        hintStyle: TextStyle(color: Color(0xFFB6BACC)),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kDividerColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kDividerColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _sending ? null : () { FocusScope.of(context).unfocus(); _sendOtp(); },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _sending ? 'Sending...' : 'Send OTP',
                                style: const TextStyle(
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

class _CountryDial {
  final String code;
  final String dial;
  const _CountryDial(this.code, this.dial);
}

