import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';
import '../session.dart';
import '../app_routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _card = TextEditingController();
  final _exp = TextEditingController();
  final _cvv = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _name.dispose();
    _card.dispose();
    _exp.dispose();
    _cvv.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _validateCard(String? v) => (v == null || v.replaceAll(' ', '').length < 12) ? 'Invalid card' : null;
  String? _validateExp(String? v) {
    if (v == null) return 'Invalid';
    final t = v.replaceAll(' ', '');
    final m = RegExp(r'^(0[1-9]|1[0-2])[/-]?(\d{2}|\d{4})$');
    return m.hasMatch(t) ? null : 'MM/YY';
  }
  String? _validateCvv(String? v) => (v == null || v.length < 3) ? 'Invalid' : null;

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    setState(() => _processing = false);
    await _createAppointmentIfNeeded();
    _showCompleted();
  }

  Future<void> _createAppointmentIfNeeded() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final mode = args?['mode'] as String?;
    if (mode == 'pro') return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final appt = appSession.appointment;
    final doctorId = appSession.doctorId;
    final doctorName = appSession.doctorName;
    if (appt == null || doctorId == null || doctorName == null) return;

    try {
      final apptRef = await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': user.uid,
        'patientName': appSession.patientName ?? user.displayName ?? '',
        'patientPhone': appSession.patientPhone ?? '',
        'patientGender': appSession.patientGender,
        'patientAgeRange': appSession.patientAgeRange,
        'patientProblem': appSession.patientProblem,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'type': appt.type,
        'period': appt.period,
        'time': appt.time,
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': 'Appointment confirmed',
        'text': 'Your appointment with $doctorName is confirmed at ${appt.time}.',
        'type': 'appointment',
        'appointmentId': apptRef.id,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (_) {}
  }

  void _showCompleted() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final mode = args?['mode'] as String?; // 'pro' for membership payment
    final type = appSession.appointment?.type ?? 'message';
    final doctor = appSession.doctorName ?? 'your doctor';
    final icon = mode == 'pro'
        ? Icons.workspace_premium_outlined
        : type == 'voice'
            ? Icons.call
            : type == 'video'
                ? Icons.videocam_outlined
                : Icons.message_outlined;

    showDialog(
      context: context,
      barrierDismissible: mode == 'pro' ? false : type != 'message',
      barrierColor: const Color(0xCC8E95A6),
      builder: (context) {
        if (mode != 'pro' && type == 'message') {
          Timer(const Duration(seconds: 2), () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
        }
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFF0F2F9),
                    child: Icon(icon, color: kTextColor, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mode == 'pro' ? 'Upgraded' : 'Completed',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextColor),
                  ),
                  const SizedBox(height: 8),
                  if (mode == 'pro')
                    const Text(
                      'Your DoctorPoint Pro Membership activated. Enjoy your Pro Membership and get unlimited consultations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kMutedTextColor, height: 1.4),
                    )
                  else
                    Text(
                      'Your appointment booking successfully completed. $doctor will ${type == 'voice' ? 'Voice Call' : type == 'video' ? 'Video Call' : 'Message'} you soon.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kMutedTextColor, height: 1.4),
                    ),
                  if (mode == 'pro' || type != 'message') ...[
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
                ],
              ),
            ),
          ),
        );
      },
    );
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
        title: const Text('Payment', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1CA796),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bank card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(height: 44, decoration: BoxDecoration(color: const Color(0xFF0F9D8A), borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Container(height: 36, decoration: BoxDecoration(color: const Color(0xFF0F9D8A), borderRadius: BorderRadius.circular(8)))),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 36, decoration: BoxDecoration(color: const Color(0xFF0F9D8A), borderRadius: BorderRadius.circular(8)))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text.rich(
                TextSpan(
                  text: 'By adding debit / credit card, you agree to the ',
                  style: TextStyle(color: kMutedTextColor),
                  children: [
                    TextSpan(text: 'Terms & Condition', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LabeledField(icon: Icons.person_outline, label: 'Name', hint: 'Enter card holder full name', controller: _name, validator: _validateNotEmpty),
                  const SizedBox(height: 12),
                  _LabeledField(icon: Icons.credit_card, label: 'Card number', hint: 'Enter card number', controller: _card, keyboardType: TextInputType.number, validator: _validateCard),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _LabeledField(icon: Icons.calendar_month_outlined, label: 'Expire date', hint: 'MM/YY', controller: _exp, validator: _validateExp)),
                      const SizedBox(width: 12),
                      Expanded(child: _LabeledField(icon: Icons.lock_outline, label: 'CVV', hint: 'Enter CVV number', controller: _cvv, keyboardType: TextInputType.number, validator: _validateCvv)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _processing ? null : _pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_processing ? 'Processing...' : 'Payment now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 20, color: const Color(0xFF9CA3B7)), const SizedBox(width: 8), Text(label, style: const TextStyle(color: kTextColor))]),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: const InputDecoration(
            hintText: '',
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDividerColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDividerColor)),
          ).copyWith(hintText: hint, hintStyle: const TextStyle(color: kMutedTextColor)),
        ),
      ],
    );
  }
}
