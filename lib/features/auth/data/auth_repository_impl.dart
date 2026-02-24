import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/result.dart';
import '../domain/auth_repository.dart';
import '../../../../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({AuthService? authService, FirebaseAuth? firebaseAuth})
      : _authService = authService ?? AuthService.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  Future<Result<User>> signInWithEmail({required String email, required String password}) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user == null) {
        return const Failure(AppFailure(message: 'Authentication failed'));
      }
      return Success(user);
    } catch (e, st) {
      return Failure(AppFailure(message: 'Sign in failed', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<User>> signUpWithEmail({required String email, required String password, required String name, String? phone}) async {
    try {
      final user = await _authService.signUpWithEmail(email: email, password: password, name: name, phone: phone);
      if (user == null) {
        return const Failure(AppFailure(message: 'Registration failed'));
      }
      return Success(user);
    } catch (e, st) {
      return Failure(AppFailure(message: 'Sign up failed', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return const Success(null);
    } catch (e, st) {
      return Failure(AppFailure(message: 'Reset email failed', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return const Success(null);
    } catch (e, st) {
      return Failure(AppFailure(message: 'Sign out failed', cause: e, stackTrace: st));
    }
  }
}
