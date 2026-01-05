import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
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
  
  // Add month and year selection
  DateTime _selectedDate = DateTime.now(); // Start with current month
  late DateTime _displayStartDate; // Start date for the selected month
  late DateTime _displayEndDate; // End date for the selected month

  @override
  void initState() {
    super.initState();
    // Initialize with current month boundaries
    _updateMonthBoundaries(_selectedDate);
  }

  // Update month boundaries based on selected date
  void _updateMonthBoundaries(DateTime date) {
    // First day of the month at 00:00:00
    _displayStartDate = DateTime(date.year, date.month, 1);
    // Last day of the month at 23:59:59.999
    _displayEndDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Navigate to previous month
  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      _updateMonthBoundaries(_selectedDate);
      touchedPie = touchedBar = -1; // Reset chart touches
    });
  }

  // Navigate to next month
  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      _updateMonthBoundaries(_selectedDate);
      touchedPie = touchedBar = -1; // Reset chart touches
    });
  }

  // Navigate to current month
  void _currentMonth() {
    setState(() {
      _selectedDate = DateTime.now();
      _updateMonthBoundaries(_selectedDate);
      touchedPie = touchedBar = -1; // Reset chart touches
    });
  }

  Color _colorFor(String cat) =>
      {
        'Food': Colors.green,
        'Shopping': Colors.orange,
        'Transport': Colors.blue,
        'Emi': Colors.red,
        'Rent': Colors.pink,
       
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
        automaticallyImplyLeading: false,
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
          
          // Get days in the selected month for bar chart
          final count = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
          final barData = List<double>.filled(count, 0);

          // Category spending map for the selected month
          final catSpend = <String, double>{};
          
          // Filter documents to only include those within the selected month
          final filtered = docs.where((doc) {
            final dt = (doc['date'] as Timestamp).toDate();
            // Check if date is within the selected month (inclusive)
            return dt.isAfter(_displayStartDate.subtract(Duration(milliseconds: 1))) && 
                   dt.isBefore(_displayEndDate.add(Duration(milliseconds: 1)));
          }).toList();

          // Also get total spending for the month
          double totalMonthSpending = 0;
          
          // Process each filtered expense document
          for (var doc in filtered) {
            final d = doc.data()! as Map<String, dynamic>;
            final amt = (d['amount'] as num).toDouble();
            final dt = (d['date'] as Timestamp).toDate();
            final category = d['category'] as String;
            
            // Add to total spending
            totalMonthSpending += amt;
            
            // Accumulate spending by category
            catSpend[category] = (catSpend[category] ?? 0) + amt;
            
            // For month view, use day of month as index (0-based)
            final idx = dt.day - 1;
            if (idx >= 0 && idx < count) barData[idx] += amt;
          }

          // Ensure touched bar index is within valid range
          final safeBar = (touchedBar >= 0 && touchedBar < count) ? touchedBar : -1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month navigation header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous month button
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: AppColors.deepPink),
                        onPressed: _previousMonth,
                      ),
                      
                      // Current month display
                      Column(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepPink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Total: \₹${totalMonthSpending.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      
                      // Next month button (disable if it's a future month)
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: AppColors.deepPink),
                        onPressed: _selectedDate.month >= DateTime.now().month && 
                                   _selectedDate.year >= DateTime.now().year
                            ? null // Disable if trying to go to future month
                            : _nextMonth,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: spacing),
                
                // Quick navigation to current month button
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.today, size: 16),
                    label: Text('Current Month'),
                    onPressed: _currentMonth,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepPink,
                      side: BorderSide(color: AppColors.deepPink),
                    ),
                  ),
                ),
                
                SizedBox(height: spacing * 2),
                
                // Spending by category section with pie chart
                if (catSpend.isNotEmpty) ...[
                  Text(
                    'Spending by Category - ${DateFormat('MMMM').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPink,
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Category statistics summary
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories: ${catSpend.length}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Transactions: ${filtered.length}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Pie chart with legend
                  SizedBox(
                    height: chartHeight,
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        
                        // Pie chart
                        Expanded(
                          child: PieChartWidget(
                            data: catSpend,
                            touchedIndex: touchedPie,
                            onTap: (i) => setState(() => touchedPie = i),
                          ),
                        ),
                        
                        SizedBox(width: 30),
                        
                        // Category legend with amounts
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: catSpend.entries.map((e) {
                                final percentage = totalMonthSpending > 0 
                                    ? (e.value / totalMonthSpending * 100).toStringAsFixed(1)
                                    : '0.0';
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: _colorFor(e.key),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              e.key,
                                              style: TextStyle(fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '\₹${e.value.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        children: [
                                          SizedBox(width: 20), // Align with color dot
                                          Text(
                                            '$percentage%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  //bar chart
                  
                  // Daily spending trend for the month
                //   Container(
                //     padding: EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(10),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black12,
                //           blurRadius: 4,
                //           offset: Offset(0, 2),
                //         ),
                //       ],
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Daily Spending Trend - ${DateFormat('MMMM').format(_selectedDate)}',
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 16,
                //             color: AppColors.deepPink,
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         SizedBox(
                //           height: chartHeight,
                //           child: BarChartWidget(
                //             data: barData,
                //             touchedIndex: safeBar,
                //             onTap: (i) => setState(() => touchedBar = i),
                //             interval: 'Month',
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ] else ...[
                //   // Show message if no expenses for selected month
                //   Container(
                //     height: height * 0.5,
                //     child: Center(
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             Icons.access_alarm,
                //             size: 60,
                //             color: Colors.grey[400],
                //           ),
                //           SizedBox(height: 20),
                //           Text(
                //             'No expenses in ${DateFormat('MMMM yyyy').format(_selectedDate)}',
                //             style: TextStyle(
                //               fontSize: 18,
                //               color: Colors.grey[600],
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //           SizedBox(height: 10),
                //           Text(
                //             'Add expenses to see your spending breakdown',
                //             style: TextStyle(
                //               color: Colors.grey[500],
                //             ),
                //             textAlign: TextAlign.center,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ],
                
                SizedBox(height: 20),
                
                // Expense list for the selected month
                if (filtered.isNotEmpty) ...[
                  Text(
                    'Recent Transactions - ${DateFormat('MMMM').format(_selectedDate)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPink,
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final amount = (data['amount'] as num).toDouble();
                      final category = data['category'] as String;
                      final description = data['description'] ?? 'No description';
                      final date = (data['date'] as Timestamp).toDate();
                      
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _colorFor(category).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: _colorFor(category),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            category,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(description),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a').format(date),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: amount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                
                SizedBox(height: 20),
              ]
        ]),
          );
        },
      ),
    );
  }
  
  // Helper method to get icons for categories
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'emi':
        return Icons.money;
      case 'rent':
        return Icons.home;
      case 'income':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }
}