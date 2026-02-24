import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../domain/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.data(null));

  Future<AppFailure?> signInWithEmail({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithEmail(email: email, password: password);
    return result.when(
      success: (user) {
        state = AsyncValue.data(user);
        return null;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return f;
      },
    );
  }

  Future<AppFailure?> signUpWithEmail({required String email, required String password, required String name, String? phone}) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signUpWithEmail(email: email, password: password, name: name, phone: phone);
    return result.when(
      success: (user) {
        state = AsyncValue.data(user);
        return null;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return f;
      },
    );
  }

  Future<AppFailure?> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.sendPasswordResetEmail(email);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return null;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return f;
      },
    );
  }

  Future<AppFailure?> signOut() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signOut();
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return null;
      },
      failure: (f) {
        state = AsyncValue.error(f, StackTrace.current);
        return f;
      },
    );
  }
}
