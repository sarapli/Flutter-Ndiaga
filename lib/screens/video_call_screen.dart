import 'dart:async';

import 'package:flutter/material.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../session.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _muted = false;
  bool _cameraOff = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    final mmStr = m.toString().padLeft(2, '0');
    final ssStr = ss.toString().padLeft(2, '0');
    return '$mmStr:$ssStr';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctor = args?['doctor'] as String? ?? appSession.doctorName ?? 'Dr. Tierra Riley';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: _cameraOff
                ? Container(color: const Color(0xFF2A2E3A))
                : Image.asset(
                    'asset/Page3.png',
                    fit: BoxFit.cover,
                  ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
          // PiP self view
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.only(top: 16, right: 16),
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('asset/Page_2.png', fit: BoxFit.cover),
              ),
            ),
          ),
          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(doctor, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_fmt(_seconds), style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CircleBtn(
                          color: const Color(0xFF178F80),
                          icon: _muted ? Icons.mic_off : Icons.mic,
                          onTap: () => setState(() => _muted = !_muted),
                        ),
                        _CircleBtn(
                          color: const Color(0xFF178F80),
                          icon: Icons.message_outlined,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.chat, arguments: {'doctor': doctor}),
                        ),
                        _CircleBtn(
                          color: const Color(0xFF178F80),
                          icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                          onTap: () => setState(() => _cameraOff = !_cameraOff),
                        ),
                        _CircleBtn(
                          color: const Color(0xFFE85151),
                          icon: Icons.call_end_rounded,
                          onTap: () => Navigator.of(context).pushReplacementNamed(
                            AppRoutes.callEnded,
                            arguments: {'doctor': doctor, 'duration': _fmt(_seconds)},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Ink(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
