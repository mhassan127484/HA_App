import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ha_ecommerce/core/constants/app_constants.dart';
import 'package:ha_ecommerce/core/errors/app_failure.dart';
import 'package:ha_ecommerce/features/auth/data/models/user_model.dart';

abstract class IAuthDataSource {
  Stream<User?> get authStateChanges;
  User? get currentFirebaseUser;
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password});
  Future<UserModel> registerWithEmailAndPassword({required String email, required String password, required String displayName});
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<UserModel> updateProfile({String? displayName, String? photoUrl, String? phoneNumber});
  Future<void> updateFcmToken({required String uid, required String token});
  Future<UserModel> reloadUser();
  Future<UserModel?> getUserFromFirestore(String uid);
}

class FirebaseAuthDataSource implements IAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    // Sync emailVerified to Firestore
    await _updateEmailVerified(user.uid, user.emailVerified);
    return _buildUserModel(user);
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await user.reload();
    final refreshed = _firebaseAuth.currentUser!;

    // Create Firestore user document
    final model = UserModel(
      uid: refreshed.uid,
      email: refreshed.email!,
      displayName: displayName,
      photoUrl: null,
      phoneNumber: null,
      emailVerified: refreshed.emailVerified,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(refreshed.uid)
        .set(model.toFirestore());
    return model;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection(FirestoreCollections.users).doc(user.uid).delete();
      await user.delete();
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser!;
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    await user.reload();

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .update(updates);

    return _buildUserModel(_firebaseAuth.currentUser!,
        extra: {'phoneNumber': phoneNumber ?? ''});
  }

  @override
  Future<void> updateFcmToken({required String uid, required String token}) =>
      _firestore.collection(FirestoreCollections.users).doc(uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<UserModel> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
    final user = _firebaseAuth.currentUser!;
    await _updateEmailVerified(user.uid, user.emailVerified);
    return _buildUserModel(user);
  }

  @override
  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _updateEmailVerified(String uid, bool verified) async {
    await _firestore.collection(FirestoreCollections.users).doc(uid).update({
      'emailVerified': verified,
    }).catchError((_) {});
  }

  UserModel _buildUserModel(User user, {Map<String, dynamic>? extra}) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: extra?['phoneNumber'] ?? user.phoneNumber,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static AuthFailure mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return AuthFailure.userNotFound();
      case 'wrong-password': return AuthFailure.wrongPassword();
      case 'email-already-in-use': return AuthFailure.emailAlreadyInUse();
      case 'weak-password': return AuthFailure.weakPassword();
      case 'invalid-email': return AuthFailure.invalidEmail();
      case 'network-request-failed': return AuthFailure.networkError();
      case 'too-many-requests': return AuthFailure.tooManyRequests();
      default: return AuthFailure.unknown(e.message ?? e.code);
    }
  }
}
