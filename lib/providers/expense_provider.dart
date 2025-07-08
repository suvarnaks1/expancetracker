import 'package:expance_tracker_app/model/expance_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _items = [];

  ExpenseProvider() {
    _init();
  }

  void _init() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseService.db
        .collection('users/$uid/expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      _items = snap.docs.map((d) => Expense.fromDoc(d)).toList();
      notifyListeners();
    });
  }

  List<Expense> get items => _items;
}
