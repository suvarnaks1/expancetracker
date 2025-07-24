import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;
import 'package:expance_tracker_app/widgets/updated_page.dart';
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
  double totalIncome = 0;
  double totalExpense = 0;

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

    double income = 0;
    double expense = 0;
    final categoryMap = <String, double>{};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final cat = data['category'] ?? 'Others';
      final amount = (data['amount'] as num).toDouble();
      final isIncome = data['type'] == 'income';

      if (isIncome) {
        income += amount;
      } else {
        expense += amount;
      }

      categoryMap[cat] = (categoryMap[cat] ?? 0) + amount;
    }

    setState(() {
      totalIncome = income;
      totalExpense = expense;
      catSpend = categoryMap;
      visibleList = activeTab == 'All'
          ? docs
          : docs.where((doc) => doc['category'] == activeTab).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final balance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                   
                  ],
                ),

                const SizedBox(height: 24),

                Text('\₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Total Balance', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                Row(
                  children: [
                    _buildInfoCard('Income', '\₹${totalIncome.toStringAsFixed(2)}',
                        Colors.green.shade100, Icons.arrow_upward),
                    const SizedBox(width: 16),
                    _buildInfoCard('Expense', '-\₹${totalExpense.toStringAsFixed(2)}',
                        Colors.red.shade100, Icons.arrow_downward),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('Your Expense',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

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
                          builder: (_) => UpdatedPage()
                        ),
                      ).then((_) => fetchTransactions()),
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

Future<void> _showAddIncomeDialog() async {
  final TextEditingController _controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Income'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final text = _controller.text;
              final amount = double.tryParse(text);
              if (amount != null && amount > 0) {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('expenses')
                    .add({
                      'amount': amount,
                      'type': 'income',
                      'category': 'Income',
                      'description': 'Added income',
                      'date': Timestamp.now(),
                    });
                  fetchTransactions();
                }
                Navigator.of(context).pop();
              } else {
                // optionally show error validation
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
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
      child: GestureDetector(
         behavior: HitTestBehavior.opaque,
            onTap: title == 'Income' ? () => _showAddIncomeDialog() : null,
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
      ),
    );
  }
}

class TransactionCardView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String date;
  final VoidCallback onEdit, onDelete;

  const TransactionCardView({
    super.key,
    required this.data,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.lightPink2, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(_iconFor(data['category']), color: AppColors.deepPink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['description'],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(data['category'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (data['type'] == 'income'
                    ? '+\$${(data['amount'] as num).toStringAsFixed(2)}'
                    : '-\$${(data['amount'] as num).toStringAsFixed(2)}'),
                style: TextStyle(
                  color: data['type'] == 'income' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          IconButton(icon: Icon(Icons.edit, color: AppColors.deepPink), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: onDelete),
        ],
      ),
    );
  }

  IconData _iconFor(String cat) {
    switch (cat) {
      case 'Food':
        return Icons.fastfood;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Transport':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }
}
