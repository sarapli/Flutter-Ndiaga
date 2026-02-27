import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_routes.dart';
import '../session.dart';
import '../agora_config.dart';
import '../services/agora_web_bridge.dart';

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
  RtcEngine? _engine;
  bool _joined = false;
  int? _remoteUid;
  String? _channelId;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  Future<void> _initAgora() async {
    // Sur le web, on passe par le bridge JavaScript (option A) pour demander les permissions caméra + micro.
    if (kIsWeb) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final doctorId = args?['doctorId'] as String? ?? appSession.doctorId ?? 'unknown';
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final channel = 'call_${userId}_$doctorId';
      agoraWebStartVideoCall(channel, userId, doctorId);
      if (mounted) {
        setState(() {
          _joined = true;
        });
      }
      return;
    }
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final doctorId = args?['doctorId'] as String? ?? appSession.doctorId ?? 'unknown';
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    _channelId = 'call_${userId}_$doctorId';

    final engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await engine.enableVideo();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (mounted) {
          setState(() {
            _joined = true;
          });
        }
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        if (mounted) {
          setState(() {
            _remoteUid = remoteUid;
          });
        }
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        if (mounted) {
          setState(() {
            _remoteUid = null;
          });
        }
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        if (mounted) {
          setState(() {
            _joined = false;
            _remoteUid = null;
          });
        }
      },
    ));

    await engine.startPreview();

    await engine.joinChannel(
      token: '',
      channelId: _channelId!,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
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
    final doctorId = args?['doctorId'] as String? ?? appSession.doctorId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: kIsWeb
                ? Image.asset(
                    'asset/Page3.png',
                    fit: BoxFit.cover,
                  )
                : _cameraOff
                    ? Container(color: const Color(0xFF2A2E3A))
                    : (_joined && _engine != null
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator())),
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
                child: _remoteUid != null && _engine != null
                    ? AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: _engine!,
                          connection: RtcConnection(channelId: _channelId!),
                          canvas: VideoCanvas(uid: _remoteUid),
                        ),
                      )
                    : const ColoredBox(color: Color(0xFF2A2E3A)),
              ),
            ),
          ),
          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x0034C1A1),
                    Color(0xFF34C1A1),
                  ],
                ),
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
                          onTap: () async {
                            final newMuted = !_muted;
                            await _engine?.muteLocalAudioStream(newMuted);
                            if (mounted) {
                              setState(() => _muted = newMuted);
                            }
                          },
                        ),
                        _CircleBtn(
                          color: const Color(0xFF178F80),
                          icon: Icons.message_outlined,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.chat, arguments: {'doctor': doctor}),
                        ),
                        _CircleBtn(
                          color: const Color(0xFF178F80),
                          icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                          onTap: () async {
                            final off = !_cameraOff;
                            await _engine?.enableLocalVideo(!off);
                            if (mounted) {
                              setState(() => _cameraOff = off);
                            }
                          },
                        ),
                        _CircleBtn(
                          color: const Color(0xFFE85151),
                          icon: Icons.call_end_rounded,
                          onTap: () {
                            _engine?.leaveChannel();
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.callEnded,
                              arguments: {
                                'doctor': doctor,
                                'doctorId': doctorId,
                                'duration': _fmt(_seconds),
                              },
                            );
                          },
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
