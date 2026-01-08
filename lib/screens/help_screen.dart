import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

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
        title: const Text('Help', style: TextStyle(color: kTextColor)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 10,
                    minLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fill out the form above to send an email and one of our team members will address your question as soon as possible.',
                    style: TextStyle(color: kMutedTextColor, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canSend
                      ? () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: const Color(0xCC8E95A6),
                            builder: (context) => Center(
                              child: Container(
                                width: 320,
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        const CircleAvatar(
                                          radius: 36,
                                          backgroundColor: Color(0xFFF0F2F9),
                                          child: Icon(Icons.mark_email_read_outlined, color: kTextColor, size: 30),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4, right: 2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF23A56F),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Mail sent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextColor)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your mail successfully sent. We will get back to you soon.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: kMutedTextColor, height: 1.4),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homePatient, (r) => false);
                                        },
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
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Send mail'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
