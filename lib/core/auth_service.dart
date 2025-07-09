import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  // Use userChanges() to listen for profile changes including email verification
  Stream<User?> get authStateChanges => _auth.userChanges();

    User? get currentUser => _auth.currentUser;
  String? get currentEmail => currentUser?.email;
  String? get currentPhotoUrl => currentUser?.photoURL;
  String? get currentDisplayName => currentUser?.displayName;

  Future<User?> signUp({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.sendEmailVerification();
    return cred.user;
  }

  Future<User?> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() => _auth.signOut();

  
  // 🎯 NEW: Update displayName and/or photoURL
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user', message: 'No user signed in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }

    await user.reload();
  }
}

