import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'widgets/barchart.dart';
import 'widgets/pichart.dart';

class ExpenseMonthView extends StatefulWidget {
  const ExpenseMonthView({super.key});
  @override
  _ExpenseMonthViewState createState() => _ExpenseMonthViewState();
}

class _ExpenseMonthViewState extends State<ExpenseMonthView> {
  String interval = 'Month';
  String activeTab = 'All';
  int touchedPie = -1, touchedBar = -1;

  Color _colorFor(String cat) =>
      {
        'Food': Colors.green,
        'Shopping': Colors.orange,
        'Transport': Colors.blue,
        'Emi': Colors.red,
        'Rent': Colors.pink,
        'Income': Colors.yellow,
      }[cat] ??
      const Color.fromARGB(255, 56, 4, 247);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width, height = size.height;
    final spacing = height * 0.02;
    final chartHeight = height * 0.25;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final stream = FirebaseFirestore.instance
        .collection('users/$uid/expenses')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Expenses')),
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
          final count = interval == 'Day'
              ? 24
              : interval == 'Week'
                  ? 7
                  : DateUtils.getDaysInMonth(now.year, now.month);
          final barData = List<double>.filled(count, 0);

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
            final d = doc.data()! as Map<String, dynamic>;
            final amt = (d['amount'] as num).toDouble();
            final dt = (d['date'] as Timestamp).toDate();
            catSpend[d['category']] = (catSpend[d['category']] ?? 0) + amt;
            final idx = interval == 'Day'
                ? dt.hour
                : interval == 'Week'
                    ? dt.weekday - 1
                    : dt.day - 1;
            if (idx >= 0 && idx < count) barData[idx] += amt;
          }

          final safeBar =
              (touchedBar >= 0 && touchedBar < count) ? touchedBar : -1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: spacing,
                children: ['Day', 'Week', 'Month'].map((lbl) {
                  final sel = interval == lbl;
                  return ChoiceChip(
                    label: Text(lbl,
                        style: TextStyle(
                            color: sel ? Colors.white : AppColors.deepPink)),
                    selected: sel,
                    selectedColor: AppColors.deepPink,
                    backgroundColor: AppColors.lightPink2,
                    onSelected: (_) => setState(() {
                      interval = lbl;
                      touchedPie = touchedBar = -1;
                    }),
                  );
                }).toList(),
              ),
              SizedBox(height: spacing),
              Text('Spending by Category',
                  style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 20),
              SizedBox(
                height: chartHeight,
                child: Row(
                  
                  children: [
                    SizedBox(width: 40,),
                    Expanded(
                      child: PieChartWidget(
                        data: catSpend,
                        touchedIndex: touchedPie,
                        onTap: (i) => setState(() => touchedPie = i),
                      ),
                    ),
                    SizedBox(width: 70),
                    Expanded(
                      child: Wrap(
                        spacing: spacing * 0.5,
                        runSpacing: spacing * 0.5,
                        children: catSpend.entries.map((e) {
                          return Column(
                            children: [
                              Row(
                                //mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: width * 0.03,
                                    height: width * 0.03,
                                    decoration: BoxDecoration(
                                      color: _colorFor(e.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(e.key,
                                      style:
                                          TextStyle(fontSize: width * 0.035)),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Text('Trend ($interval)',
              //     style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: spacing),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: chartHeight,
                  child: BarChartWidget(
                    data: barData,
                    touchedIndex: safeBar,
                    onTap: (i) => setState(() => touchedBar = i),
                    interval: interval,
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
