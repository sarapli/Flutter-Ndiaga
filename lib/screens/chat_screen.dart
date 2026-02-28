import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

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
  String? _doctorId;
  bool _recording = false;
  final AudioRecorder _recorder = AudioRecorder();

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
    final doctorId = args?['doctorId'] as String? ?? appSession.doctorId;
    if (_doctor != doctor || _doctorId != doctorId) {
      _doctor = doctor;
      _doctorId = doctorId;
      _initConversation();
    }
  }

  Future<void> _initConversation() async {
    final otherId = _doctorId ?? 'doc:${_doctor ?? 'unknown'}';
    final id = await ChatService.instance.ensureConversation(otherId: otherId, otherName: _doctor);
    if (!mounted) return;
    setState(() => _convId = id);
    // Marquer la conversation comme lue pour l'utilisateur courant
    await ChatService.instance.markAsRead(id);
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
                          if (type == 'audio') {
                            return Align(
                              alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: _AudioBubble(url: m['url'] ?? ''),
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
            onMic: _onMic,
            isRecording: _recording,
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

  Future<void> _onMic() async {
    if (_convId == null) return;
    if (kIsWeb) {
      final url = await StorageService.instance.pickAndUploadAudio();
      if (url != null) {
        await ChatService.instance.sendMedia(_convId!, url: url, type: 'audio');
      }
      return;
    }
    if (!_recording) {
      final has = await _recorder.hasPermission();
      if (!has) return;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: filePath,
      );
      if (!mounted) return;
      setState(() => _recording = true);
    } else {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() => _recording = false);
      if (path == null) return;
      final url = await StorageService.instance.uploadAudioPath(path);
      if (url != null) {
        await ChatService.instance.sendMedia(_convId!, url: url, type: 'audio');
      }
    }
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
  final VoidCallback? onMic;
  final bool isRecording;
  final bool canSend;
  const _Composer({required this.controller, this.onAttach, this.onSend, this.onMic, this.isRecording = false, this.canSend = true});

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
              if (!hasText) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor),
                  child: IconButton(
                    onPressed: widget.canSend ? widget.onMic : null,
                    icon: Icon(widget.isRecording ? Icons.stop_rounded : Icons.mic, color: Colors.white),
                  ),
                ),
              ] else ...[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: kPrimaryColor,
                  child: IconButton(
                    onPressed: widget.canSend ? widget.onSend : null,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  final String url;
  const _AudioBubble({required this.url});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  late final AudioPlayer _player;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((s) {
      final playing = s.playing && s.processingState != ProcessingState.completed;
      if (mounted) setState(() => _playing = playing);
    });
    _player.setUrl(widget.url);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              if (_playing) {
                await _player.pause();
              } else {
                await _player.play();
              }
            },
            icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill, color: kPrimaryColor, size: 28),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.graphic_eq, color: Color(0xFF9CA3B7)),
          const SizedBox(width: 8),
          StreamBuilder<Duration?>(
            stream: _player.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final mm = pos.inMinutes.remainder(60).toString().padLeft(2, '0');
              final ss = pos.inSeconds.remainder(60).toString().padLeft(2, '0');
              return Text('$mm:$ss', style: const TextStyle(color: kTextColor));
            },
          ),
        ],
      ),
    );
  }
}
