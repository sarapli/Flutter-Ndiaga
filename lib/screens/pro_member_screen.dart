import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class ProMemberScreen extends StatelessWidget {
  const ProMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Become a pro member', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(child: _PlanCard(title: '3 Months plan', price: '80', selected: false)),
                SizedBox(width: 12),
                Expanded(child: _PlanCard(title: '6 Months plan', price: '150', selected: true)),
                SizedBox(width: 12),
                Expanded(child: _PlanCard(title: '1 year plan', price: '300', selected: false)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('They talk about us', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const _Testimonial(name: 'Alex', text: 'Used it for 1 month only. The way it is displayed and the way information is given is very good.'),
            const SizedBox(height: 10),
            const _Testimonial(name: 'John', text: 'It\'s awesome, a very good companion for your most prior health, easy navigation to find your doctor.'),
            const SizedBox(height: 10),
            const _Testimonial(name: 'Sara', text: 'Great service and quick access to specialists!'),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final bool selected;
  const _PlanCard({required this.title, required this.price, required this.selected});

  @override
  Widget build(BuildContext context) {
    // Sanitize any odd characters from provided price and render as $<digits>
    final digits = RegExp(r'[0-9]+').allMatches(price).map((m) => m.group(0)!).join();
    final displayPrice = digits.isEmpty ? price : '\$$digits';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
        border: Border.all(color: selected ? kPrimaryColor : kDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: selected ? Colors.white : kTextColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _bullet('Covers 1 adult', selected),
          _bullet('Connect with a doctor under 60 seconds', selected),
          _bullet('Doctor available to chat, voice & video call', selected),
          _bullet('Unlimited consultant', selected),
          const SizedBox(height: 12),
          Text(displayPrice, style: TextStyle(color: selected ? Colors.white : kTextColor, fontSize: 20, fontWeight: FontWeight.w700)),
          const Text('user/month', style: TextStyle(color: kMutedTextColor, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.payment, arguments: {'mode': 'pro'}),
              style: ElevatedButton.styleFrom(
                backgroundColor: selected ? Colors.white : kPrimaryColor,
                foregroundColor: selected ? kPrimaryColor : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get started'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: selected ? Colors.white : kPrimaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: selected ? Colors.white : kTextColor, fontSize: 12))),
        ],
      ),
    );
  }
}

class _Testimonial extends StatelessWidget {
  final String name;
  final String text;
  const _Testimonial({required this.name, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFE9EBF2), radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.star, color: Color(0xFFFF9130), size: 16),
                  Icon(Icons.star, color: Color(0xFFFF9130), size: 16),
                  Icon(Icons.star, color: Color(0xFFFF9130), size: 16),
                  Icon(Icons.star, color: Color(0xFFFF9130), size: 16),
                  Icon(Icons.star, color: Color(0xFFFF9130), size: 16),
                ]),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(color: kTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
