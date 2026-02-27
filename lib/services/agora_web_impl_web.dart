// Web implementation using JavaScript interop.

import 'dart:js' as js;

void agoraWebStartVoiceCall(String channelId, String uid, String doctor) {
  js.context.callMethod('agoraWebStartVoiceCall', [channelId, uid, doctor]);
}

void agoraWebStartVideoCall(String channelId, String uid, String doctor) {
  js.context.callMethod('agoraWebStartVideoCall', [channelId, uid, doctor]);
}

void agoraWebMute(bool muted) {
  js.context.callMethod('agoraWebMute', [muted]);
}

void agoraWebToggleCamera(bool enabled) {
  js.context.callMethod('agoraWebToggleCamera', [enabled]);
}

void agoraWebHangup() {
  js.context.callMethod('agoraWebHangup');
}
