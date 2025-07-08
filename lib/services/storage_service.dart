import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final uid;
  StorageService(this.uid);

  Future<String> uploadReceipt(File file) async {
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref('users/$uid/receipts/$name.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}
