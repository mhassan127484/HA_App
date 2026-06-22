import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> registerWithEmail({required String email, required String password, required String displayName});
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile({String? displayName, String? photoUrl, String? phoneNumber});
  Future<void> updateFcmToken(String token);
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  CollectionReference get _users => _firestore.collection(AppConstants.usersCollection);

  @override
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    try {
      final doc = await _users.doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  });

  @override
  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) throw const AuthException(message: 'Sign in failed');

      final doc = await _users.doc(user.uid).get();
      if (!doc.exists) throw const AuthException(message: 'User profile not found');

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) throw const AuthException(message: 'Registration failed');

      await user.updateDisplayName(displayName);
      await user.sendEmailVerification();

      final model = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: AppConstants.roleCustomer,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );

      await _users.doc(user.uid).set(model.toMap());
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(message: 'Not authenticated');

    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) throw const AuthException(message: 'User profile not found');
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(message: 'Not authenticated');

    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    final updateData = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (displayName != null) updateData['displayName'] = displayName;
    if (photoUrl != null) updateData['photoUrl'] = photoUrl;
    if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

    await _users.doc(user.uid).update(updateData);
    return getCurrentUser();
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _users.doc(user.uid).update({'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(message: 'Not authenticated');
    await _users.doc(user.uid).update({'isActive': false});
    await user.delete();
  }

  String _mapFirebaseAuthError(String code) => switch (code) {
    'user-not-found'        => 'No account found with this email',
    'wrong-password'        => 'Incorrect password',
    'email-already-in-use'  => 'This email is already registered',
    'invalid-email'         => 'Please enter a valid email address',
    'weak-password'         => 'Password must be at least 6 characters',
    'user-disabled'         => 'This account has been disabled',
    'too-many-requests'     => 'Too many attempts. Please try again later',
    'network-request-failed'=> 'Network error. Check your connection',
    _                       => 'Authentication failed. Please try again',
  };
}
