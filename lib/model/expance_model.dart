import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'description': description,
        'category': category,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory Expense.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (d['amount'] as num).toDouble(),
      description: d['description'] as String,
      category: d['category'] as String,
      date: (d['date'] as Timestamp).toDate(),
    );
  }
}
