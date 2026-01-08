import 'package:flutter/material.dart';

import '../app_style.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final List<_Contact> _contacts = List.generate(
    10,
    (i) => _Contact(name: [
      'Aoseph S. O\'Neill',
      'Arnold L. Beal',
      'Bames Forkan Mason',
      'Cyrus J. Perez',
      'Doshua Porgue Spillane',
      'Drian G. Neeley',
      'Doshua M. Wilson',
      'Evan T. Nixon',
      'Floyd R. Brooks',
      'Gavin Q. Stone',
    ][i]),
  );

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
        title: const Text('Invite a friend', style: TextStyle(color: kTextColor)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SegmentedTabs(controller: _tabs),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ContactsList(contacts: _contacts),
          const _FacebookTab(),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final TabController controller;
  const _SegmentedTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: kTextColor,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: _TabContent(
              icon: Icons.contacts_outlined,
              label: 'Contacts',
            ),
          ),
          Tab(
            child: _TabContent(
              icon: Icons.facebook_outlined,
              label: 'Facebook',
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsList extends StatefulWidget {
  final List<_Contact> contacts;
  const _ContactsList({required this.contacts});

  @override
  State<_ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<_ContactsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: widget.contacts.length,
      itemBuilder: (context, i) {
        final c = widget.contacts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
          ),
          child: Row(
            children: [
              _Avatar(name: c.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: c.invited
                      ? ElevatedButton(
                          key: const ValueKey('invited'),
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23A56F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Invited'),
                        )
                      : OutlinedButton(
                          key: const ValueKey('invite'),
                          onPressed: () => setState(() => c.invited = true),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8EAF0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            foregroundColor: kPrimaryColor,
                          ),
                          child: const Text('Invite'),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FacebookTab extends StatelessWidget {
  const _FacebookTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.facebook_outlined, size: 48, color: kMutedTextColor),
            SizedBox(height: 12),
            Text('Connect your Facebook account to invite friends.', textAlign: TextAlign.center, style: TextStyle(color: kMutedTextColor)),
          ],
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TabContent({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color ?? kTextColor;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Icon(icon, size: 16, color: kPrimaryColor),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: const Color(0xFFE9EBF2),
        child: Center(
          child: Text(letter, style: const TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _Contact {
  final String name;
  bool invited;
  _Contact({required this.name}) : invited = false;
}
