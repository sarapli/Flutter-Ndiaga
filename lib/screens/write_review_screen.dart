import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0; // 0..5
  final TextEditingController _comment = TextEditingController();
  bool? _recommend; // true/false

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _canSubmit => _rating > 0 && _comment.text.trim().isNotEmpty && _recommend != null;

  void _showCompleted(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFEFF7F5),
                  child: Icon(Icons.format_quote, color: kPrimaryColor),
                ),
                const SizedBox(height: 12),
                const Icon(Icons.check_circle, color: kPrimaryColor),
                const SizedBox(height: 12),
                const Text('Completed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: kTextColor)),
                const SizedBox(height: 8),
                const Text(
                  'Your review was submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kMutedTextColor),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Go to dashboard'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? 'Dr. Mahmud Nik';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Write a review', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const ColoredBox(color: Color(0xFFE9EBF2), child: SizedBox(width: 84, height: 84)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'How was your experience with $doctor ? ',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kTextColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _rating;
                return IconButton(
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(filled ? Icons.star : Icons.star_border, color: const Color(0xFFFF9130), size: 28),
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(
              children: const [
                Text('Write a comment', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
                Spacer(),
                Text('Max 450 Words', style: TextStyle(color: kMutedTextColor, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tell people about your experience',
                filled: true,
                fillColor: const Color(0xFFF7F8FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Would you recommend this doctor to your friends?', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ChoiceChip(
                  label: 'Yes',
                  selected: _recommend == true,
                  onTap: () => setState(() => _recommend = true),
                ),
                const SizedBox(width: 10),
                _ChoiceChip(
                  label: 'No',
                  selected: _recommend == false,
                  onTap: () => setState(() => _recommend = false),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canSubmit ? () => _showCompleted(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit review'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kPrimaryColor : kDividerColor),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : kTextColor)),
      ),
    );
  }
}
