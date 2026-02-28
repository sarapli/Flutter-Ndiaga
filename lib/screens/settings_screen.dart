import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../services/auth_service.dart';
import '../session.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBottomBar;
  const SettingsScreen({super.key, this.showBottomBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notif = false;
  String _language = 'English ( United States )';

  @override
  void initState() {
    super.initState();
    final code = appSession.locale?.languageCode;
    _language = _labelFor(code);
  }

  void _openLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => _LanguageDialog(current: _language),
    );
    if (selected != null) {
      await _applyLanguage(selected);
    }
  }

  Future<void> _applyLanguage(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final code = _codeFor(label);
    await prefs.setString('locale', code);
    appSession.setLocale(Locale(code));
    if (mounted) setState(() => _language = label);
  }

  String _codeFor(String label) {
    if (label.startsWith('Francais')) return 'fr';
    if (label.startsWith('Bangla')) return 'bn';
    if (label.startsWith('Nederlands')) return 'nl';
    return 'en';
  }

  String _labelFor(String? code) {
    switch (code) {
      case 'fr':
        return 'Francais ( Franch )';
      case 'bn':
        return 'Bangla ( Bangladesh )';
      case 'nl':
        return 'Nederlands ( Nedarlend )';
      default:
        return 'English ( United States )';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = appSession.role == UserRole.doctor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: kTextColor)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Builder(
            builder: (context) {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                return _HeaderCard(
                  onEdit: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                  name: 'Guest',
                  photoUrl: null,
                );
              }
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final rawName = data?['name'] as String?;
                  final authName = user.displayName;
                  final name = (rawName != null && rawName.trim().isNotEmpty)
                      ? rawName.trim()
                      : (authName != null && authName.trim().isNotEmpty)
                          ? authName.trim()
                          : null;
                  final photoUrl = data?['photoUrl'] as String?;
                  final avatarAsset = data?['avatarAsset'] as String?;
                  return _HeaderCard(
                    onEdit: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                    name: name ?? 'Hello',
                    avatarAsset: avatarAsset,
                    photoUrl: photoUrl,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          if (!isDoctor) ...[
            _SettingsTile(
              leading: Icons.workspace_premium_outlined,
              title: 'Become a pro member',
              trailing: const Icon(Icons.chevron_right, color: kMutedTextColor),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.proMember),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: _tileBoxDecoration(),
            child: Row(
              children: [
                const Icon(Icons.notifications_none, color: kPrimaryColor),
                const SizedBox(width: 12),
                const Expanded(child: Text('Notification', style: TextStyle(color: kTextColor))),
                Switch(
                  value: _notif,
                  activeThumbColor: kPrimaryColor,
                  activeTrackColor: const Color(0xFFBFE5DF),
                  onChanged: (v) => setState(() => _notif = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            leading: Icons.translate,
            title: 'Language',
            subtitle: _language,
            trailing: const Icon(Icons.chevron_right, color: kMutedTextColor),
            onTap: _openLanguage,
          ),
          const SizedBox(height: 8),
          if (!isDoctor) ...[
            _SettingsTile(
              leading: Icons.person_add_alt,
              title: 'Invite a friend',
              trailing: const Icon(Icons.chevron_right, color: kMutedTextColor),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.inviteFriend),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              leading: Icons.favorite_border,
              title: 'Favourite doctors',
              trailing: const Icon(Icons.chevron_right, color: kMutedTextColor),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.favouriteDoctors),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              leading: Icons.help_outline,
              title: 'FAQs',
              trailing: const Icon(Icons.chevron_right, color: kMutedTextColor),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.faqs),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              leading: Icons.support_outlined,
              title: 'Help',
              trailing: const Icon(Icons.chevron_right, color: kMutedTextColor),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.help),
            ),
            const SizedBox(height: 8),
          ],
          _SettingsTile(
            leading: Icons.logout,
            title: 'Logout',
            onTap: () async {
              final nav = Navigator.of(context);
              await AuthService.instance.signOut();
              nav.pushNamedAndRemoveUntil(AppRoutes.signIn, (r) => false);
            },
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomBar ? const _BottomBar(index: 4) : null,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final VoidCallback onEdit;
  final String? name;
  final String? avatarAsset;
  final String? photoUrl;
  const _HeaderCard({required this.onEdit, this.name, this.avatarAsset, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: _buildAvatar(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello!', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 2),
                Text(
                  (name == null || name!.isEmpty) ? 'User' : name!,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            color: Colors.white,
            onSelected: (_) => onEdit(),
            itemBuilder: (_) => const [
              PopupMenuItem<int>(value: 1, child: Text('Edit Profile')),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: const Icon(Icons.more_horiz, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarAsset != null && avatarAsset!.isNotEmpty) {
      return Image.asset(avatarAsset!, fit: BoxFit.cover);
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(photoUrl!, fit: BoxFit.cover);
    }
    return Image.asset('asset/Profile.png', fit: BoxFit.cover);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.leading, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: _tileBoxDecoration(),
        child: Row(
          children: [
            Icon(leading, color: kPrimaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: kTextColor)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(color: kMutedTextColor, fontSize: 12)),
                  ],
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _tileBoxDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
    );

class _LanguageDialog extends StatelessWidget {
  final String current;
  const _LanguageDialog({required this.current});

  @override
  Widget build(BuildContext context) {
    final options = const [
      'Bangla ( Bangladesh )',
      'English ( United Kingdom )',
      'English ( United States )',
      'Francais ( Franch )',
      'Nederlands ( Nedarlend )',
    ];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select language', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final o in options) ...[
              ListTile(
                title: Text(o, style: const TextStyle(color: kTextColor)),
                trailing: o == current ? const Icon(Icons.check, color: kPrimaryColor) : null,
                onTap: () => Navigator.of(context).pop(o),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  const _BottomBar({required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: const Color(0xFFB6BACC),
      currentIndex: index,
      onTap: (i) {
        if (i == 0) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.homePatient);
        } else if (i == 1) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.notifications);
        } else if (i == 2) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.search);
        } else if (i == 3) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.appointments);
        } else if (i == 4) {
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Appts'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Settings'),
      ],
    );
  }
}
