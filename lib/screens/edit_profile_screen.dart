import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Mahmudul Hasan Manik');
  final _phone = TextEditingController(text: '2562 358 987');
  final _password = TextEditingController(text: '@12587#12568');
  String _gender = 'Male';
  DateTime _dob = DateTime(1995, 9, 15);
  bool _obscure = true;
  String? _photoUrl;
  String? _role;
  String? _avatarAsset;
  bool _loading = false;
  String _phoneCode = '+254';
  String _countryCode = 'KE';
  bool _isGoogleUser = false;

  static const List<_Country> _countries = [
    _Country('SN', 'Senegal', '+221', '🇸🇳'),
    _Country('CI', 'Côte d\'Ivoire', '+225', '🇨🇮'),
    _Country('ML', 'Mali', '+223', '🇲🇱'),
    _Country('GN', 'Guinée', '+224', '🇬🇳'),
    _Country('FR', 'France', '+33', '🇫🇷'),
    _Country('GB', 'United Kingdom', '+44', '🇬🇧'),
    _Country('US', 'United States', '+1', '🇺🇸'),
    _Country('NL', 'Netherlands', '+31', '🇳🇱'),
    _Country('BD', 'Bangladesh', '+880', '🇧🇩'),
    _Country('MA', 'Maroc', '+212', '🇲🇦'),
    _Country('DZ', 'Algérie', '+213', '🇩🇿'),
    _Country('TN', 'Tunisie', '+216', '🇹🇳'),
    _Country('NG', 'Nigeria', '+234', '🇳🇬'),
    _Country('KE', 'Kenya', '+254', '🇰🇪'),
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');
    }
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();
    final data = snap.data();
    if (data == null) return;
    setState(() {
      _name.text = (data['name'] as String?) ?? _name.text;
      _phone.text = (data['phone'] as String?) ?? _phone.text;
      _gender = (data['gender'] as String?) ?? _gender;
      final ts = data['dob'];
      if (ts is Timestamp) _dob = ts.toDate();
      _photoUrl = data['photoUrl'] as String?;
      _role = data['role'] as String?;
      _avatarAsset = data['avatarAsset'] as String?;
      _phoneCode = (data['phoneCode'] as String?) ?? _phoneCode;
      _countryCode = (data['countryCode'] as String?) ?? _countryCode;
    });
  }

  Future<void> _pickPhoto() async {
    final url = await StorageService.instance.pickAndUploadImage();
    if (url == null) return;
    setState(() => _photoUrl = url);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1960),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Widget _buildProfileImage() {
    // Pour les médecins, on privilégie l'avatarAsset s'il est présent
    if (_role == 'doctor' && _avatarAsset != null && _avatarAsset!.isNotEmpty) {
      return Image.asset(_avatarAsset!, fit: BoxFit.cover);
    }
    // Sinon, on garde le comportement existant: photoUrl ou avatar patient par défaut
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(_photoUrl!, fit: BoxFit.cover);
    }
    return Image.asset('asset/Profile.png', fit: BoxFit.cover);
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
        title: const Text('Edit profile', style: TextStyle(color: kTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _buildProfileImage(),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: kPrimaryColor,
                        child: IconButton(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Labeled('Name'),
              TextFormField(
                controller: _name,
                decoration: _inputDecoration('Mahmudul Hasan Manik'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _Labeled('Phone number'),
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
                          final c = _countries.firstWhere((e) => e.dial == v);
                          setState(() {
                            _phoneCode = c.dial;
                            _countryCode = c.code;
                          });
                        },
                        items: [
                          for (final c in _countries)
                            DropdownMenuItem(
                              value: c.dial,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(c.flag, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(c.dial, style: const TextStyle(color: kTextColor)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('2562 358 987'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isGoogleUser) ...[
                _Labeled('Password'),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: _inputDecoration('@12587#12568').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF9CA3B7)),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 16),
              ],
              _Labeled('Gender'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kDividerColor),
                ),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(border: InputBorder.none),
                  initialValue: _gender,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                ),
              ),
              const SizedBox(height: 16),
              _Labeled('Date of birth'),
              InkWell(
                onTap: _pickDob,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kDividerColor),
                  ),
                  child: Text(_formatDate(_dob), style: const TextStyle(color: kTextColor)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) return;
                          final nav = Navigator.of(context);
                          final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                          final firstTime = routeArgs?['firstTime'] == true;
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          setState(() => _loading = true);
                          try {
                            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                              'name': _name.text.trim(),
                              'phone': _phone.text.trim(),
                              'phoneCode': _phoneCode,
                              'countryCode': _countryCode,
                              'gender': _gender,
                              'dob': _dob,
                              'photoUrl': _photoUrl,
                              'updatedAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                          if (firstTime) {
                            final role = _role ?? 'patient';
                            // Si le profil est complété pour la première fois :
                            // - les patients vont sur homePatient
                            // - les docteurs vont sur le shellDoctor (dashboard médecin moderne)
                            nav.pushNamedAndRemoveUntil(
                              role == 'doctor' ? AppRoutes.shellDoctor : AppRoutes.homePatient,
                              (r) => false,
                            );
                          } else {
                            nav.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_loading ? 'Saving...' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F8FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}

class _Labeled extends StatelessWidget {
  final String text;
  const _Labeled(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
    );
  }
}

class _Country {
  final String code;
  final String name;
  final String dial;
  final String flag;
  const _Country(this.code, this.name, this.dial, this.flag);
}
