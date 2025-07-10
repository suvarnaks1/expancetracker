import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;
import 'package:expance_tracker_app/view/additems/add_items.dart';
import 'package:expance_tracker_app/view/expance/expancemonthview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  String activeTab = 'All';
  List<DocumentSnapshot> visibleList = [];
  Map<String, double> catSpend = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();

    final docs = querySnapshot.docs;

    setState(() {
      visibleList = activeTab == 'All'
          ? docs
          : docs.where((doc) => doc['category'] == activeTab).toList();

      catSpend = {};
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final cat = data['category'] ?? 'Others';
        final amount = (data['amount'] as num).toDouble();
        catSpend[cat] = (catSpend[cat] ?? 0) + amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.userChanges(),
                      builder: (context, snapshot) {
                        final user = snapshot.data;

                        return Row(
                          children: [
                            if (user?.photoURL != null)
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(user!.photoURL!),
                              ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                               'Hey, ${user?.displayName ?? 'User'}!',

                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (user?.email != null)
                                  Text(
                                    user!.email!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const Icon(
                      Icons.notifications_none,
                      color: AppColors.deepPink,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Balance
                const Text('\$4,586.00',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Total Balance', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Income and Expense Cards
                Row(
                  children: [
                    _buildInfoCard('Income', '\$2,450.00', Colors.green.shade100,
                        Icons.arrow_upward),
                    const SizedBox(width: 16),
                    _buildInfoCard('Expense', '-\$710.00', Colors.red.shade100,
                        Icons.arrow_downward),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('Your Expense',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: ['All', ...catSpend.keys].map((tab) {
                    final sel = tab == activeTab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: sel,
                        selectedColor: AppColors.deepPink,
                        backgroundColor: AppColors.lightPink2,
                        labelStyle: TextStyle(
                            color: sel ? Colors.white : AppColors.deepPink),
                        onSelected: (_) {
                          setState(() => activeTab = tab);
                          fetchTransactions();
                        },
                      ),
                    );
                  }).toList()),
                ),
                const SizedBox(height: 16),

                // Transactions List
                ...visibleList.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final dt = (d['date'] as Timestamp).toDate();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TransactionCardView(
                      data: d,
                      date: DateFormat.yMMMd().format(dt),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddItems(
                            existingId: doc.id,
                            initialAmount: d['amount'].toDouble(),
                            initialDesc: d['description'],
                            initialCategory: d['category'],
                            initialDate: dt,
                          ),
                        ),
                      ),
                      onDelete: () => _confirmDelete(uid!, doc.id),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String uid, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .doc('users/$uid/expenses/$id')
                    .delete();
                Navigator.pop(context);
                fetchTransactions();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String amount, Color bgColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon,
              color: bgColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(amount,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// Make sure you have this file: transaction_card_view.dart with TransactionCardView widget
