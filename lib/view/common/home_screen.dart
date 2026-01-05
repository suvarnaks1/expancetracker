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
  
  // Store the original documents separately
  List<DocumentSnapshot> allExpensesDocs = [];
  List<DocumentSnapshot> allIncomeDocs = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  // Fetch ALL transactions (both expenses and income)
  Future<void> fetchTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Fetch from expenses collection
      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      // Fetch from income collection
      final incomeSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('income')
          .orderBy('date', descending: true)
          .get();

      // Store original documents
      allExpensesDocs = expensesSnapshot.docs;
      allIncomeDocs = incomeSnapshot.docs;

      // Combine both lists for display
      final allDocs = [...expensesSnapshot.docs, ...incomeSnapshot.docs];
      
      // Sort combined list by date (newest first)
      allDocs.sort((a, b) {
        final aDate = (a.data()['date'] as Timestamp).toDate();
        final bDate = (b.data()['date'] as Timestamp).toDate();
        return bDate.compareTo(aDate);
      });

      double income = 0;
      double expense = 0;
      final categoryMap = <String, double>{};

      // Process all documents
      for (var doc in allDocs) {
        final data = doc.data();
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
            ? allDocs
            : allDocs.where((doc) => doc['category'] == activeTab).toList();
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final balance = (totalIncome - totalExpense).clamp(0.0, double.infinity);

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes')),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Get current user info
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
                                  Text(
                                    "This is Your MoneyMeter",
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
                      // Notification icon
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text('\₹${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text('Total Balance',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoCard(
                          'Income',
                          '\₹${totalIncome.toStringAsFixed(2)}',
                          Colors.green.shade100,
                          Icons.arrow_upward),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                          'Expense',
                          '-\₹${totalExpense.toStringAsFixed(2)}',
                          Colors.red.shade100,
                          Icons.arrow_downward),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Your Transactions',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
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
                  // Transaction list
                  if (visibleList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
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
                                builder: (_) => UpdatedPage(docId: doc.id)),
                          ).then((_) => fetchTransactions()),
                          onDelete: () => _confirmDelete(uid!, doc),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show dialog to add income (Simplified - no description field)
  Future<void> _showAddIncomeDialog() async {
    final TextEditingController _controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Income'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter amount', 
                      labelText: 'Amount'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final text = _controller.text.trim();
                final amount = double.tryParse(text);
                if (amount != null && amount > 0) {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('income')
                          .add({
                        'amount': amount,
                        'type': 'income',
                        'category': 'Income',
                        'description': 'Income added',
                        'date': Timestamp.now(),
                      });
                      fetchTransactions();
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error adding income: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to add income. Try again.')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid amount')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Delete transaction - pass the entire document to get correct type and ID
  void _confirmDelete(String uid, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] ?? 'expense'; // Default to expense if not specified
    final docId = doc.id;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Determine which collection to delete from
              final collection = type == 'income' ? 'income' : 'expenses';
              
              FirebaseFirestore.instance
                  .doc('users/$uid/$collection/$docId')
                  .delete()
                  .then((_) {
                Navigator.pop(context);
                fetchTransactions(); // Refresh the list
              }).catchError((error) {
                print('Error deleting: $error');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete. Try again.'),
                  ),
                );
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
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
    final isIncome = data['type'] == 'income';
    final amount = (data['amount'] as num).toDouble();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightPink2,
        borderRadius: BorderRadius.circular(12),
        border: isIncome 
            ? Border.all(color: Colors.green.shade200, width: 1)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              _iconFor(data['category']),
              color: isIncome ? Colors.green : AppColors.deepPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['description'],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text(data['category'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isIncome
                    ? '+\₹${amount.toStringAsFixed(2)}'
                    : '-\₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(date,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          IconButton(
              icon: Icon(Icons.edit,
                  color: isIncome ? Colors.green : AppColors.deepPink),
              onPressed: onEdit),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: onDelete),
        ],
      ),
    );
  }

  IconData _iconFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      case 'income':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }
}