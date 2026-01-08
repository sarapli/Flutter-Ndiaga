import 'package:flutter/material.dart';

import '../app_style.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  final List<_FaqItem> _items = const [
    _FaqItem(
      q: 'Are there any type of doctors who are not included in DoctorPoint Pro consultation network?',
      a: 'All members of your Pro Membership healthcare plan will have access to their own team of doctors on the DoctorPoint app across 20 Specialities. You will be able to communicate with the doctor through messaging, voice and video call. Each consultation will be free of cost, and will be completely private.',
    ),
    _FaqItem(
      q: 'How do the unlimited online consultations work',
      a: 'You can start a consultation anytime from the app. Once connected, you can chat, call or video call with an available doctor. There is no per-consultation fee under Pro Membership.',
    ),
    _FaqItem(
      q: 'How many online consultations can I use?',
      a: 'There is no hard cap for consultations under the Pro plan, subject to fair usage and availability.',
    ),
    _FaqItem(
      q: 'Will family members can be able to use my account?',
      a: 'Currently the membership is individual. Family plans are coming soon.',
    ),
    _FaqItem(
      q: 'How many members can be part of one DoctorPoint Pro Membership?',
      a: 'One member per plan at this time. We will notify you when family bundles are available.',
    ),
  ];

  final Set<int> _expanded = {1};

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
        title: const Text('FAQs', style: TextStyle(color: kTextColor)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: kDividerColor),
        itemBuilder: (context, i) {
          final it = _items[i];
          final isOpen = _expanded.contains(i);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(it.q, style: const TextStyle(color: kTextColor)),
                trailing: Icon(isOpen ? Icons.expand_less : Icons.chevron_right, color: kMutedTextColor),
                onTap: () => setState(() {
                  if (isOpen) {
                    _expanded.remove(i);
                  } else {
                    _expanded.add(i);
                  }
                }),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(it.a, style: const TextStyle(color: kMutedTextColor, height: 1.4)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}
