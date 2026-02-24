import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/result.dart';

abstract interface class AuthRepository {
  Stream<User?> authStateChanges();

  Future<Result<User>> signInWithEmail({required String email, required String password});

  Future<Result<User>> signUpWithEmail({required String email, required String password, required String name, String? phone});

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();
}
