import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../session.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _convId;
  String? _doctor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? appSession.doctorName ?? 'Dr. Mahmud Nik';
    if (_doctor != doctor) {
      _doctor = doctor;
      _initConversation();
    }
  }

  Future<void> _initConversation() async {
    final otherId = 'doc:${_doctor ?? 'unknown'}';
    final id = await ChatService.instance.ensureConversation(otherId: otherId, otherName: _doctor);
    if (!mounted) return;
    setState(() => _convId = id);
  }

  @override
  Widget build(BuildContext context) {
    final doctor = _doctor ?? appSession.doctorName ?? 'Dr. Mahmud Nik';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(doctor, style: const TextStyle(color: kTextColor)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _SquareAction(
              icon: Icons.call,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.voiceCall, arguments: {'doctor': doctor}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: _SquareAction(
              icon: Icons.videocam_outlined,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.videoCall, arguments: {'doctor': doctor}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _SquareAction(
              icon: Icons.more_horiz,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.messageEnded, arguments: {'doctor': doctor}),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _convId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: ChatService.instance.streamMessages(_convId!),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      final me = FirebaseAuth.instance.currentUser?.uid;
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemBuilder: (context, i) {
                          final m = docs[i].data();
                          final fromMe = m['from'] == me;
                          final type = m['type'] as String? ?? 'text';
                          if (type == 'image') {
                            return Align(
                              alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  m['url'] ?? '',
                                  width: 220,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                          if (type == 'video') {
                            return Align(
                              alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: 220,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9EBF2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.play_circle_fill, size: 48, color: kPrimaryColor),
                              ),
                            );
                          }
                          return fromMe
                              ? _PatientBubble(text: m['text'] ?? '')
                              : _DoctorBubble(text: m['text'] ?? '');
                        },
                        separatorBuilder: (_, i) => const SizedBox(height: 10),
                        itemCount: docs.length,
                      );
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            onAttach: _onAttach,
            onSend: _onSend,
            canSend: _convId != null,
          ),
        ],
      ),
    );
  }

  Future<void> _onAttach() async {
    if (_convId == null) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Image'),
              onTap: () => Navigator.of(ctx).pop('image'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Video'),
              onTap: () => Navigator.of(ctx).pop('video'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    String? url;
    if (choice == 'image') {
      url = await StorageService.instance.pickAndUploadImage();
      if (url != null) {
        await ChatService.instance.sendMedia(_convId!, url: url, type: 'image');
      }
    } else if (choice == 'video') {
      url = await StorageService.instance.pickAndUploadVideo();
      if (url != null) {
        await ChatService.instance.sendMedia(_convId!, url: url, type: 'video');
      }
    }
  }

  Future<void> _onSend() async {
    if (_convId == null) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ChatService.instance.sendText(_convId!, text);
    if (!mounted) return;
    _controller.clear();
  }
}

class _SquareAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kDividerColor),
        ),
        child: Icon(icon, color: kPrimaryColor),
      ),
    );
  }
}

// (Removed unused _TimeLabel and _TypingLabel)

class _PatientBubble extends StatelessWidget {
  final String text;
  const _PatientBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(color: kTextColor)),
      ),
    );
  }
}

class _DoctorBubble extends StatelessWidget {
  final String text;
  const _DoctorBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE9EBF2)),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

// (Removed unused _ImageBubble and _AudioBubble)

class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onAttach;
  final VoidCallback? onSend;
  final bool canSend;
  const _Composer({required this.controller, this.onAttach, this.onSend, this.canSend = true});

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  bool get hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F9D8A).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.canSend ? widget.onAttach : null,
                icon: const Icon(Icons.attach_file_rounded, color: kPrimaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: 'Type something . . .',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: kPrimaryColor,
                child: IconButton(
                  onPressed: widget.canSend ? widget.onSend : null,
                  icon: Icon(hasText ? Icons.send_rounded : Icons.mic, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
