import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'google_sign_in_stub.dart' if (dart.library.io) 'google_sign_in_io.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ConfirmationResult? _webPhoneConfirmation;

  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ensureUserDoc(cred.user);
    return cred.user;
  }

  Future<User?> signUpWithEmail({required String email, required String password, required String name, String? phone}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'patient',
    }, SetOptions(merge: true));
    return cred.user;
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final cred = await _auth.signInWithPopup(provider);
      await _ensureUserDoc(cred.user);
      return cred.user;
    } else {
      final cred = await signInWithGoogleMobile(_auth);
      if (cred == null) return null;
      await _ensureUserDoc(cred.user);
      return cred.user;
    }
  }

  Future<User?> signInWithFacebook() async {
    if (kIsWeb) {
      final provider = FacebookAuthProvider();
      final cred = await _auth.signInWithPopup(provider);
      await _ensureUserDoc(cred.user);
      return cred.user;
    } else {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;
      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final cred = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(cred.user);
      return cred.user;
    }
  }

  Future<String> sendOtp(String phone, {Duration timeout = const Duration(seconds: 60)}) async {
    if (kIsWeb) {
      _webPhoneConfirmation = await _auth.signInWithPhoneNumber(phone);
      return 'web';
    }
    final c = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: timeout,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final cred = await _auth.signInWithCredential(credential);
        await _ensureUserDoc(cred.user);
        if (!c.isCompleted) c.complete('AUTO');
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!c.isCompleted) c.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!c.isCompleted) c.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!c.isCompleted) c.complete(verificationId);
      },
    );
    return c.future;
  }

  Future<User?> verifyOtp({required String verificationId, required String smsCode}) async {
    if (kIsWeb && verificationId == 'web') {
      final result = await _webPhoneConfirmation!.confirm(smsCode);
      await _ensureUserDoc(result.user);
      return result.user;
    }
    final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final cred = await _auth.signInWithCredential(credential);
    await _ensureUserDoc(cred.user);
    return cred.user;
  }

  Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email);

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await signOutGoogleMobile();
      } catch (_) {}
      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {}
    }
  }

  Future<void> _ensureUserDoc(User? user) async {
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    await ref.set({
      'email': user.email,
      'phone': user.phoneNumber,
      'name': user.displayName,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
