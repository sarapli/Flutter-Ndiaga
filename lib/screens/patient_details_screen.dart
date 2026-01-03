import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  String name = 'Mahmudul Hasan Manik';
  String? ageRange;
  String phone = '';
  String? gender;
  final TextEditingController _problem = TextEditingController();

  @override
  void dispose() {
    _problem.dispose();
    super.dispose();
  }

  bool get canContinue => ageRange != null && gender != null && phone.isNotEmpty && _problem.text.trim().isNotEmpty;

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
        title: const Text("Patient's details", style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.person_outline, color: kMutedTextColor),
                SizedBox(width: 8),
                Text('Name', style: TextStyle(color: kMutedTextColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: kTextColor)),
            const Divider(color: kDividerColor),

            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.calendar_month_outlined, color: kMutedTextColor),
                SizedBox(width: 8),
                Text('Select your age range or type', style: TextStyle(color: kMutedTextColor)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                _AgeChip(label: '10+', selected: ageRange == '10+', onTap: () => setState(() => ageRange = '10+')),
                _AgeChip(label: '20+', selected: ageRange == '20+', onTap: () => setState(() => ageRange = '20+')),
                _AgeChip(label: '30+', selected: ageRange == '30+', onTap: () => setState(() => ageRange = '30+')),
                _AgeChip(label: 'Other', selected: ageRange == 'Other', onTap: () => setState(() => ageRange = 'Other')),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.call_outlined, color: kMutedTextColor),
                SizedBox(width: 8),
                Text('Phone number', style: TextStyle(color: kMutedTextColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('+254', style: TextStyle(color: kMutedTextColor)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => setState(() => phone = v.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number',
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDividerColor)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDividerColor)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.people_outline, color: kMutedTextColor),
                SizedBox(width: 8),
                Text('Gender', style: TextStyle(color: kMutedTextColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _GenderOption(
                  label: 'Male',
                  selected: gender == 'Male',
                  onTap: () => setState(() => gender = 'Male'),
                ),
                const SizedBox(width: 14),
                _GenderOption(
                  label: 'Female',
                  selected: gender == 'Female',
                  onTap: () => setState(() => gender = 'Female'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text('Write your problem', style: TextStyle(color: kMutedTextColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _problem,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tell doctor about your problem',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDividerColor),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        Navigator.of(context).pushNamed(AppRoutes.payment);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AgeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFFE7F3F1),
      onSelected: (_) => onTap(),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F3F1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kPrimaryColor : kDividerColor),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                size: 18, color: selected ? kPrimaryColor : const Color(0xFFCBCDD6)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: kTextColor)),
          ],
        ),
      ),
    );
  }
}
