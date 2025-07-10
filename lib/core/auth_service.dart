import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  

  
  //Register

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print('registration error:$e');
      rethrow;
    }
  }

  //Login

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print('Login Rrror:$e');
    }
  }

  //Logout
   Future<void> signOut() async {
    await _auth.signOut();
  }


//get current User
   User? getCurrentUser() {
    return _auth.currentUser;
  }


 

 

}

