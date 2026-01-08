import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDEcz9GjmD3pA4uxlEfPEc5b0kHjWjFmvE',
          authDomain: 'flutter-hospital-6a5bf.firebaseapp.com',
          projectId: 'flutter-hospital-6a5bf',
          storageBucket: 'flutter-hospital-6a5bf.firebasestorage.app',
          messagingSenderId: '511584538184',
          appId: '1:511584538184:web:d33598737a842dbed3527d',
          measurementId: 'G-EWW9H8LQ6R',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    _initialized = true;
  }
}
