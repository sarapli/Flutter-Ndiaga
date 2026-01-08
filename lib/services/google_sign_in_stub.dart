import 'package:firebase_auth/firebase_auth.dart';

// Stub for web or platforms without dart:io
Future<UserCredential?> signInWithGoogleMobile(FirebaseAuth auth) async {
  return null; // Not applicable on web; we use signInWithPopup instead.
}

Future<void> signOutGoogleMobile() async {
  // No-op on web.
}
