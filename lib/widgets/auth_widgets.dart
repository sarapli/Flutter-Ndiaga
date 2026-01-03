import 'package:flutter/material.dart';

import '../app_style.dart';

class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefix;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefix,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: kTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
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

class PhoneField extends StatelessWidget {
  final String label;

  const PhoneField({super.key, this.label = 'Phone number'});

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
              label,
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
            Row(
              children: const [
                Text(
                  '+254',
                  style: TextStyle(fontSize: 14.5, color: Color(0xFFB6BACC)),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFFB6BACC),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
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
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        SocialBox(
          background: Color(0xFF2F5A9B),
          child: Icon(Icons.facebook, color: Colors.white),
        ),
        SizedBox(width: 16),
        SocialBox(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDB4437),
            ),
          ),
        ),
        SizedBox(width: 16),
        SocialBox(
          child: Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
        ),
        SizedBox(width: 16),
        SocialBox(
          child: Icon(Icons.camera_alt_outlined, color: Color(0xFFE1306C)),
        ),
      ],
    );
  }
}

class SocialBox extends StatelessWidget {
  final Widget child;
  final Color? background;

  const SocialBox({super.key, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: background == null ? Border.all(color: kDividerColor) : null,
      ),
      alignment: Alignment.center,
      child: child,
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
  const Keypad({super.key});

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
          return Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: kTextColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
