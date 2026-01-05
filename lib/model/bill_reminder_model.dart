
import 'package:cloud_firestore/cloud_firestore.dart';

class BillReminder {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime dueDate;
  final DateTime? reminderDate;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;

  BillReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.reminderDate,
    this.isPaid = false,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'reminderDate': reminderDate != null ? Timestamp.fromDate(reminderDate!) : null,
      'isPaid': isPaid,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static BillReminder fromMap(String id, Map<String, dynamic> map) {
    return BillReminder(
      id: id,
      title: map['title'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      reminderDate: map['reminderDate'] != null ? (map['reminderDate'] as Timestamp).toDate() : null,
      isPaid: map['isPaid'] ?? false,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}