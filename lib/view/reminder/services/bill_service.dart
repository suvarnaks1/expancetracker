import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/model/bill_reminder_model.dart';
import 'package:flutter/material.dart';

class BillService {
  // Fetch all bills for the current user
  static Future<List<BillReminder>> fetchBills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('billReminders')
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => BillReminder.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching bills: $e');
      return [];
    }
  }

  // Add a new bill
  static Future<bool> addBill({
    required String title,
    required double amount,
    required String category,
    required DateTime dueDate,
    DateTime? reminderDate,
    String? notes,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('billReminders')
          .add({
        'title': title,
        'amount': amount,
        'category': category,
        'dueDate': Timestamp.fromDate(dueDate),
        'reminderDate': reminderDate != null ? Timestamp.fromDate(reminderDate) : null,
        'isPaid': false,
        'notes': notes,
        'createdAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error adding bill: $e');
      return false;
    }
  }

  // Mark bill as paid
  static Future<bool> markAsPaid(String billId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('billReminders')
          .doc(billId)
          .update({
        'isPaid': true,
        'paidAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error marking bill as paid: $e');
      return false;
    }
  }

  // Delete a bill
  static Future<bool> deleteBill(String billId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('billReminders')
          .doc(billId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting bill: $e');
      return false;
    }
  }

  // Calculate bill statistics
  static Map<String, dynamic> calculateStatistics(List<BillReminder> bills) {
    final now = DateTime.now();
    double upcomingTotal = 0;
    int overdue = 0;
    int upcoming = 0;
    int paid = 0;

    for (var bill in bills) {
      if (bill.isPaid) {
        paid++;
      } else {
        if (bill.dueDate.isBefore(now)) {
          overdue++;
        } else {
          upcoming++;
          upcomingTotal += bill.amount;
        }
      }
    }

    return {
      'totalUpcomingAmount': upcomingTotal,
      'overdueCount': overdue,
      'upcomingCount': upcoming,
      'paidCount': paid,
      'totalBills': bills.length,
    };
  }

  // Filter bills based on status
  static List<BillReminder> filterBills(List<BillReminder> bills, String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'all':
        return List.from(bills);
      case 'upcoming':
        return bills
            .where((bill) => !bill.isPaid && bill.dueDate.isAfter(now))
            .toList();
      case 'overdue':
        return bills
            .where((bill) => !bill.isPaid && bill.dueDate.isBefore(now))
            .toList();
      case 'paid':
        return bills.where((bill) => bill.isPaid).toList();
      default:
        return List.from(bills);
    }
  }

  // Get icon for bill category
  static IconData getBillIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electricity':
        return Icons.bolt;
      case 'water':
        return Icons.water_drop;
      case 'internet':
      case 'phone':
        return Icons.wifi;
      case 'rent':
        return Icons.home;
      case 'credit card':
        return Icons.credit_card;
      case 'loan':
        return Icons.account_balance;
      case 'subscription':
        return Icons.subscriptions;
      case 'insurance':
        return Icons.security;
      case 'gas':
        return Icons.local_gas_station;
      default:
        return Icons.receipt;
    }
  }

  // Available bill categories
  static List<String> get categories => [
    'Electricity',
    'Water',
    'Internet',
    'Rent',
    'Credit Card',
    'Loan',
    'Subscription',
    'Insurance',
    'Phone',
    'Gas',
    'Other'
  ];
}