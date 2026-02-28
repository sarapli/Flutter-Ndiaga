import 'package:flutter/material.dart';

import '../app_style.dart';

class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefix;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefix,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(prefix, size: 22, color: const Color(0xFF9CA3B7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: kTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB6BACC)),
            suffixIcon: suffix,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kDividerColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kDividerColor),
            ),
          ),
        ),
      ],
    );
  }
}

class PhoneField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;

  const PhoneField({super.key, this.label = 'Phone number', this.controller});

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  String _dialCode = '+254';
  String _localNumber = '';

  Future<void> _pickCountryCode() async {
    final codes = <String>['+221', '+225', '+237', '+254'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Select country code', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              for (final c in codes)
                ListTile(
                  title: Text(c),
                  onTap: () => Navigator.of(ctx).pop(c),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() {
        _dialCode = selected;
      });
      widget.controller?.text = '$_dialCode$_localNumber';
    }
  }

  void _onNumberChanged(String value) {
    _localNumber = value;
    widget.controller?.text = value.isEmpty ? '' : '$_dialCode$value';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.call_outlined, size: 22, color: Color(0xFF9CA3B7)),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: const TextStyle(
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
            InkWell(
              onTap: _pickCountryCode,
              child: Row(
                children: [
                  Text(
                    _dialCode,
                    style: const TextStyle(fontSize: 14.5, color: Color(0xFFB6BACC)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color(0xFFB6BACC),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                onChanged: _onNumberChanged,
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
    );
  }
}

class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: kDividerColor, thickness: 1)),
        const SizedBox(width: 14),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFFB6BACC)),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Divider(color: kDividerColor, thickness: 1)),
      ],
    );
  }
}

class SocialRow extends StatelessWidget {
  final VoidCallback? onFacebook;
  final VoidCallback? onGoogle;
  final VoidCallback? onInstagram;
  const SocialRow({super.key, this.onFacebook, this.onGoogle, this.onInstagram});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SocialBox(
          background: const Color(0xFF2F5A9B),
          onTap: onFacebook,
          child: const Icon(Icons.facebook, color: Colors.white),
        ),
        const SizedBox(width: 16),
        SocialBox(
          onTap: onGoogle,
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDB4437),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SocialBox(
          child: const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
        ),
        const SizedBox(width: 16),
        SocialBox(
          onTap: onInstagram ?? onFacebook,
          child: const Icon(Icons.camera_alt_outlined, color: Color(0xFFE1306C)),
        ),
      ],
    );
  }
}

class SocialBox extends StatelessWidget {
  final Widget child;
  final Color? background;
  final VoidCallback? onTap;

  const SocialBox({super.key, required this.child, this.background, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: background ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: background == null ? Border.all(color: kDividerColor) : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class BottomQuestionLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const BottomQuestionLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFFB6BACC)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class BackSquareButton extends StatelessWidget {
  final VoidCallback onTap;

  const BackSquareButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kDividerColor),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF9CA3B7)),
      ),
    );
  }
}

class OtpBox extends StatelessWidget {
  final String text;
  final bool active;

  const OtpBox({super.key, required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDividerColor),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: active ? kPrimaryColor : kTextColor,
        ),
      ),
    );
  }
}

class Keypad extends StatelessWidget {
  final ValueChanged<String>? onKey;
  const Keypad({super.key, this.onKey});

  @override
  Widget build(BuildContext context) {
    const keys = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 18,
          crossAxisSpacing: 24,
          childAspectRatio: 1.6,
        ),
        itemBuilder: (context, index) {
          final label = keys[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: label.isEmpty ? null : () => onKey?.call(label),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OtpDisplay extends StatelessWidget {
  final String code;
  final int length;
  const OtpDisplay({super.key, required this.code, this.length = 6});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        final ch = i < code.length ? code[i] : '';
        return OtpBox(text: ch, active: i == code.length);
      }),
    );
  }
}
