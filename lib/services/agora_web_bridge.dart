import 'package:flutter/foundation.dart';

import 'agora_web_stub.dart'
    if (dart.library.js) 'agora_web_impl_web.dart' as impl;

void agoraWebStartVoiceCall(String channelId, String uid, String doctor) {
  if (!kIsWeb) return;
  impl.agoraWebStartVoiceCall(channelId, uid, doctor);
}

void agoraWebStartVideoCall(String channelId, String uid, String doctor) {
  if (!kIsWeb) return;
  impl.agoraWebStartVideoCall(channelId, uid, doctor);
}

void agoraWebMute(bool muted) {
  if (!kIsWeb) return;
  impl.agoraWebMute(muted);
}

void agoraWebToggleCamera(bool enabled) {
  if (!kIsWeb) return;
  impl.agoraWebToggleCamera(enabled);
}

void agoraWebHangup() {
  if (!kIsWeb) return;
  impl.agoraWebHangup();
}
