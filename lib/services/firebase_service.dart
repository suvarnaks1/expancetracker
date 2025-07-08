import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future init() => Firebase.initializeApp();
  static FirebaseFirestore get db => FirebaseFirestore.instance;
}
