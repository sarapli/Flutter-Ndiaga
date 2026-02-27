// Minimal Agora Web option A: just request permissions and log activity.

console.log('agora_web.js loaded');

window.agoraWebStartVoiceCall = function (channelId, uid, doctor) {
  console.log('[AgoraWeb] Start voice call', { channelId, uid, doctor });
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    console.warn('[AgoraWeb] getUserMedia not supported in this browser');
    return;
  }
  navigator.mediaDevices
    .getUserMedia({ audio: true })
    .then(function (stream) {
      console.log('[AgoraWeb] Microphone permission granted', stream);
    })
    .catch(function (err) {
      console.error('[AgoraWeb] Microphone permission denied', err);
    });
};

window.agoraWebStartVideoCall = function (channelId, uid, doctor) {
  console.log('[AgoraWeb] Start video call', { channelId, uid, doctor });
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    console.warn('[AgoraWeb] getUserMedia not supported in this browser');
    return;
  }
  navigator.mediaDevices
    .getUserMedia({ audio: true, video: true })
    .then(function (stream) {
      console.log('[AgoraWeb] Camera & mic permission granted', stream);
    })
    .catch(function (err) {
      console.error('[AgoraWeb] Camera/mic permission denied', err);
    });
};

window.agoraWebMute = function (muted) {
  console.log('[AgoraWeb] Mute toggled', { muted });
};

window.agoraWebToggleCamera = function (enabled) {
  console.log('[AgoraWeb] Camera toggled', { enabled });
};

window.agoraWebHangup = function () {
  console.log('[AgoraWeb] Hangup');
};
