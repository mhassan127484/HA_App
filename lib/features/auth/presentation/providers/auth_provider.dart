import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// ── Infrastructure providers ───────────────────────────────────────
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) =>
    AuthRemoteDataSourceImpl(
      auth: ref.read(firebaseAuthProvider),
      firestore: ref.read(firestoreProvider),
    ));

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(remoteDataSource: ref.read(authRemoteDataSourceProvider)));

// ── Use Case providers ─────────────────────────────────────────────
final signInUseCaseProvider = Provider<SignInUseCase>(
    (ref) => SignInUseCase(ref.read(authRepositoryProvider)));

final registerUseCaseProvider = Provider<RegisterUseCase>(
    (ref) => RegisterUseCase(ref.read(authRepositoryProvider)));

// ── Auth State ─────────────────────────────────────────────────────
final authStateProvider = StreamProvider<UserEntity?>((ref) =>
    ref.read(authRepositoryProvider).authStateChanges);

// ── Auth State Notifier ────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
    bool? isSuccess,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    user: user ?? this.user,
    errorMessage: errorMessage,
    isSuccess: isSuccess ?? this.isSuccess,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SignInUseCase _signIn;
  final RegisterUseCase _register;

  AuthNotifier({
    required AuthRepository repository,
    required SignInUseCase signIn,
    required RegisterUseCase register,
  })  : _repository = repository,
        _signIn = signIn,
        _register = register,
        super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _signIn(SignInParams(email: email, password: password));
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user, isSuccess: true);
        return true;
      },
    );
  }

  Future<bool> register(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _register(RegisterParams(
      email: email, password: password, displayName: displayName,
    ));
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user, isSuccess: true);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = const AuthState();
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.sendPasswordResetEmail(email);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }

  Future<bool> resendVerification() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.sendEmailVerification();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) =>
    AuthNotifier(
      repository: ref.read(authRepositoryProvider),
      signIn: ref.read(signInUseCaseProvider),
      register: ref.read(registerUseCaseProvider),
    ));

/// Convenience: current logged-in user (nullable)
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// App-wide theme mode — persists in memory (could be extended to shared_prefs)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
