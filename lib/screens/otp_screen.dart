import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  String? _verificationId;
  String? _phone;
  bool _verifying = false;

  static const int _length = 6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _verificationId ??= args?['verificationId'] as String?;
    _phone ??= args?['phone'] as String?;
  }

  Future<void> _onKey(String key) async {
    if (_verifying) return;
    if (key == '⌫') {
      if (_code.isNotEmpty) setState(() => _code = _code.substring(0, _code.length - 1));
      return;
    }
    if (_code.length >= _length) return;
    setState(() => _code += key);
    if (_code.length == _length) {
      await _verify();
    }
  }

  Future<void> _verify() async {
    setState(() => _verifying = true);
    try {
      final user = await AuthService.instance.verifyOtp(verificationId: _verificationId ?? 'web', smsCode: _code);
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushNamed(AppRoutes.resetPassword);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _code = '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid code: $e')));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    try {
      final id = await AuthService.instance.sendOtp(_phone ?? '');
      setState(() {
        _verificationId = id;
        _code = '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resend failed: $e')));
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
                  constraints: BoxConstraints(maxWidth: isWideLayout(context) ? 520 : double.infinity),
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
                      Text(
                        'Put the OTP number below sent to ${_phone ?? 'your number'}',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: kMutedTextColor,
                        ),
                      ),
                      const SizedBox(height: 28),
                      OtpDisplay(code: _code, length: _length),
                      const SizedBox(height: 22),
                      Center(
                        child: Text(
                          _verifying ? 'Verifying...' : 'Code valid for 1:00',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFB6BACC)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: InkWell(
                          onTap: _verifying ? null : _resend,
                          child: const Text(
                            'Resend code',
                            style: TextStyle(fontSize: 13, color: kPrimaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Keypad(onKey: _onKey),
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
