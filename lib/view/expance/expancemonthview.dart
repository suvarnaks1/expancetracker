import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/view/additems/add_items.dart';
import 'widgets/barchart.dart';
import 'widgets/pichart.dart';

class ExpenseMonthView extends StatefulWidget {
  const ExpenseMonthView({super.key});
  @override
  State<ExpenseMonthView> createState() => _ExpenseMonthViewState();
}

class _ExpenseMonthViewState extends State<ExpenseMonthView> {
  String interval = 'Month'; // can be 'Day', 'Week', or 'Month'
  String activeTab = 'All';
  int touchedPie = -1, touchedBar = -1;

  Color _colorFor(String cat) =>
      {
        'Food': Colors.green,
        'Shopping': Colors.orange,
        'Transport': Colors.blue,
        'Emi':Colors.red,
        'Rent':Colors.black,
        'income':Colors.yellow
      }[cat] ??
      Colors.grey;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final stream = FirebaseFirestore.instance
        .collection('users/$uid/expenses')
        .orderBy('date', descending: true)
        .snapshots();

    return 
      WillPopScope(
  onWillPop: () async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
        ],
      ),
    );
    return shouldExit ?? false;
  },
      child: Scaffold(
          appBar: AppBar(
          title: Center(child:  Text('Expance')),
          backgroundColor: AppColors.deepPink,
          foregroundColor: Colors.white,
        ),
        backgroundColor: AppColors.lightPink1,
        body: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            final now = DateTime.now();
      
            // ✔ Use DateUtils to get accurate days-per-month
            final int count = interval == 'Day'
                ? 24
                : interval == 'Week'
                    ? 7
                    : DateUtils.getDaysInMonth(now.year, now.month);
            final barData = List<double>.filled(count, 0);
      
            // Determine interval start boundary
            final start = interval == 'Day'
                ? DateTime(now.year, now.month, now.day)
                : interval == 'Week'
                    ? now.subtract(Duration(days: now.weekday - 1))
                    : DateTime(now.year, now.month, 1);
      
            final catSpend = <String, double>{};
            final filtered = docs.where((doc) {
              final dt = (doc['date'] as Timestamp).toDate();
              return !dt.isBefore(start);
            }).toList();
      
            for (var doc in filtered) {
              final d = doc.data() as Map<String, dynamic>;
              final amt = (d['amount'] as num).toDouble();
              final dt = (d['date'] as Timestamp).toDate();
      
              catSpend[d['category']] = (catSpend[d['category']] ?? 0) + amt;
      
              final idx = interval == 'Day'
                  ? dt.hour
                  : interval == 'Week'
                      ? dt.weekday - 1
                      : dt.day - 1;
      
              if (idx >= 0 && idx < count) {
                barData[idx] += amt;
              }
            }
      
            final safeTouchedBar =
                (touchedBar >= 0 && touchedBar < count) ? touchedBar : -1;
      
            final visibleList = filtered.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return activeTab == 'All' || d['category'] == activeTab;
            }).toList();
      
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            
                const SizedBox(height: 16),
      
                Row(
                  children: ['Day', 'Week', 'Month'].map((lbl) {
                    final selected = interval == lbl;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(lbl,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.deepPink)),
                        selected: selected,
                        selectedColor: AppColors.deepPink,
                        backgroundColor: AppColors.lightPink2,
                        onSelected: (_) => setState(() {
                          interval = lbl;
                          touchedBar = touchedPie = -1;
                        }),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
      
                // — Pie Chart
                Text('Spending by Category',
                    style: Theme.of(context).textTheme.titleMedium),
      
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChartWidget(
                          data: catSpend,
                          touchedIndex: touchedPie,
                          onTap: (i) => setState(() => touchedPie = i),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: catSpend.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _colorFor(e.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(e.key,
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
      
                const SizedBox(height: 24),
      
                // — Bar Chart
                Text('Trend ($interval)',
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(
                  height: 200,
                  child: BarChartWidget(
                    data: barData,
                    touchedIndex: safeTouchedBar,
                    onTap: (i) => setState(() => touchedBar = i),
                    interval: interval,
                  ),
                ),
               
            
      
        
              ]),
            );
          },
        ),
      ),
    );
  }


}

// Transaction card widget
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['description'],
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(data['category'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('-\$${(data['amount'] as num).toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            Text(date,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          IconButton(
              icon: Icon(Icons.edit, color: AppColors.deepPink),
              onPressed: onEdit),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: onDelete),
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
