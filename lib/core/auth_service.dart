import 'package:firebase_auth/firebase_auth.dart';

/// Possible authentication result statuses.
enum AuthStatus {
  success,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  operationNotAllowed,
  userNotFound,
  wrongPassword,
  userDisabled,
  tooManyRequests,
  accountExistsWithDifferentCredential,
  unknownError,
}

/// A structured result object returned by auth operations.
class AuthResult {
  final User? user;
  final AuthStatus status;
  final String? message;

  AuthResult({this.user, required this.status, this.message});
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Registers a new user with email and password.
  Future<AuthResult> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return AuthResult(user: cred.user, status: AuthStatus.success);
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        user: null,
        status: _mapRegisterErrorCode(e.code),
        message: e.message,
      );
    } catch (e) {
      return AuthResult(
          user: null, status: AuthStatus.unknownError, message: e.toString());
    }
  }

  /// Signs in an existing user.
  Future<AuthResult> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AuthResult(user: cred.user, status: AuthStatus.success);
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        user: null,
        status: _mapLoginErrorCode(e.code),
        message: e.message,
      );
    } catch (e) {
      return AuthResult(
          user: null, status: AuthStatus.unknownError, message: e.toString());
    }
  }

  Future<void> signOut() async => await _auth.signOut();
  User? getCurrentUser() => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Maps Firebase error codes for registration.
  AuthStatus _mapRegisterErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AuthStatus.emailAlreadyInUse;
      case 'invalid-email':
        return AuthStatus.invalidEmail;
      case 'weak-password':
        return AuthStatus.weakPassword;
      case 'operation-not-allowed':
        return AuthStatus.operationNotAllowed;
      default:
        return AuthStatus.unknownError;
    }
  }

  /// Maps Firebase error codes for login.
  AuthStatus _mapLoginErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthStatus.userNotFound;
      case 'wrong-password':
        return AuthStatus.wrongPassword;
      case 'user-disabled':
        return AuthStatus.userDisabled;
      case 'too-many-requests':
        return AuthStatus.tooManyRequests;
      case 'invalid-email':
        return AuthStatus.invalidEmail;
      case 'operation-not-allowed':
        return AuthStatus.operationNotAllowed;
      case 'account-exists-with-different-credential':
        return AuthStatus.accountExistsWithDifferentCredential;
      default:
        return AuthStatus.unknownError;
    }
  }
}
