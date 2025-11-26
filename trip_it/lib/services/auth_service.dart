import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> authState() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password, {String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user!.updateDisplayName(displayName);
    }
    // Create/merge a basic profile document for the user (non-blocking on web)
    _db
        .collection('users')
        .doc(cred.user!.uid)
        .set({
          'email': cred.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          if (displayName != null && displayName.isNotEmpty) 'displayName': displayName,
        }, SetOptions(merge: true))
        .catchError((_) {
          // Intentionally ignore to avoid blocking navigation when rules misconfigured
        });
    return cred;
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
