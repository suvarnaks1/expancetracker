// Import necessary Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/resources/colors.dart';  // Custom color definitions
import 'widgets/barchart.dart';  // Custom bar chart widget
import 'widgets/pichart.dart';   // Custom pie chart widget

// Main widget class for displaying monthly expense view
class ExpenseMonthView extends StatefulWidget {
  const ExpenseMonthView({super.key});
  
  @override
  // Create state for this widget
  _ExpenseMonthViewState createState() => _ExpenseMonthViewState();
}

// State class for ExpenseMonthView widget
class _ExpenseMonthViewState extends State<ExpenseMonthView> {
  // State variables
  String interval = 'Month';        // Current time interval: Day, Week, or Month
  String activeTab = 'All';         // Currently active filter tab
  int touchedPie = -1;              // Index of touched pie chart segment (-1 = none)
  int touchedBar = -1;              // Index of touched bar chart bar (-1 = none)

  // Helper method to get color for each expense category
  Color _colorFor(String cat) =>
      {
        // Map category names to colors
        'Food': Colors.green,
        'Shopping': Colors.orange,
        'Transport': Colors.blue,
        'Emi': Colors.red,
        'Rent': Colors.pink,
        'Income': Colors.yellow,
      }[cat] ??  // Return mapped color or default blue if category not found
      const Color.fromARGB(255, 56, 4, 247);  // Default color

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final spacing = height * 0.02;      // Responsive spacing
    final chartHeight = height * 0.25;  // Height for chart widgets

    // Get current user ID from Firebase Authentication
    final uid = FirebaseAuth.instance.currentUser!.uid;
    
    // Create Firestore stream to listen for expense data changes
    // Orders documents by date in descending order (newest first)
    final stream = FirebaseFirestore.instance
        .collection('users/$uid/expenses')
        .orderBy('date', descending: true)
        .snapshots();

    // Main scaffold widget
    return Scaffold(
      // App bar with title and styling
      appBar: AppBar(
        title: Center(child: Text('Expenses')),
        backgroundColor: AppColors.deepPink,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.lightPink1,
      
      // Body using StreamBuilder to handle real-time Firestore data
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,  // Firestore data stream
        builder: (_, snap) {
          // Show loading indicator while data is being fetched
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract documents from Firestore snapshot
          final docs = snap.data!.docs;
          final now = DateTime.now();
          
          // Determine the number of bars needed based on selected interval
          final count = interval == 'Day'
              ? 24  // 24 hours for day view
              : interval == 'Week'
                  ? 7  // 7 days for week view
                  : DateUtils.getDaysInMonth(now.year, now.month);  // Days in month for month view
          
          // Initialize bar chart data array with zeros
          final barData = List<double>.filled(count, 0);

          // Calculate start date based on selected interval
          final start = interval == 'Day'
              ? DateTime(now.year, now.month, now.day)  // Start of current day
              : interval == 'Week'
                  ? now.subtract(Duration(days: now.weekday - 1))  // Start of current week
                  : DateTime(now.year, now.month, 1);  // Start of current month

          // Dictionary to track spending by category
          final catSpend = <String, double>{};
          
          // Filter documents to only include those within the selected time interval
          final filtered = docs.where((doc) {
            final dt = (doc['date'] as Timestamp).toDate();  // Convert Firestore timestamp to DateTime
            return !dt.isBefore(start);  // Keep only documents with date >= start date
          }).toList();

          // Process each filtered expense document
          for (var doc in filtered) {
            final d = doc.data()! as Map<String, dynamic>;
            final amt = (d['amount'] as num).toDouble();  // Get amount as double
            final dt = (d['date'] as Timestamp).toDate();  // Get date
            final category = d['category'] as String;
            
            // Accumulate spending by category
            catSpend[category] = (catSpend[category] ?? 0) + amt;
            
            // Calculate index for bar chart placement based on interval
            final idx = interval == 'Day'
                ? dt.hour  // Hour index for day view
                : interval == 'Week'
                    ? dt.weekday - 1  // Day of week index (0-6) for week view
                    : dt.day - 1;  // Day of month index for month view
            
            // Add amount to appropriate bar chart position
            if (idx >= 0 && idx < count) barData[idx] += amt;
          }

          // Ensure touched bar index is within valid range
          final safeBar = (touchedBar >= 0 && touchedBar < count) ? touchedBar : -1;

          // Main content layout with scrolling
          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interval selection chips (Day, Week, Month)
                Wrap(
                  spacing: spacing,
                  children: ['Day', 'Week', 'Month'].map((lbl) {
                    final sel = interval == lbl;  // Check if this interval is selected
                    return ChoiceChip(
                      label: Text(lbl,
                          style: TextStyle(
                              color: sel ? Colors.white : AppColors.deepPink)),
                      selected: sel,
                      selectedColor: AppColors.deepPink,
                      backgroundColor: AppColors.lightPink2,
                      // Update interval and reset chart touches when chip is selected
                      onSelected: (_) => setState(() {
                        interval = lbl;
                        touchedPie = touchedBar = -1;
                      }),
                    );
                  }).toList(),
                ),
                SizedBox(height: spacing),  // Spacer
                
                // Spending by category section
                Text('Spending by Category',
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 20),
                
                // Pie chart with category legend
                SizedBox(
                  height: chartHeight,
                  child: Row(
                    children: [
                      SizedBox(width: 40),  // Left padding
                      
                      // Pie chart widget showing category distribution
                      Expanded(
                        child: PieChartWidget(
                          data: catSpend,
                          touchedIndex: touchedPie,
                          onTap: (i) => setState(() => touchedPie = i),  // Update touched pie index
                        ),
                      ),
                      SizedBox(width: 70),  // Spacing between chart and legend
                      
                      // Category legend (color + name)
                      Expanded(
                        child: Wrap(
                          spacing: spacing * 0.5,
                          runSpacing: spacing * 0.5,
                          children: catSpend.entries.map((e) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // Color indicator circle
                                    Container(
                                      width: width * 0.03,
                                      height: width * 0.03,
                                      decoration: BoxDecoration(
                                        color: _colorFor(e.key),  // Get color for category
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),  // Spacing
                                    // Category name
                                    Text(e.key,
                                        style: TextStyle(fontSize: width * 0.035)),
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
                SizedBox(height: 30),  // Spacer
                
                // Bar chart section showing spending trend over time
                // SizedBox(height: spacing),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: SizedBox(
                //     height: chartHeight,
                //     // Bar chart widget
                //     child: BarChartWidget(
                //       data: barData,  // Processed bar chart data
                //       touchedIndex: safeBar,  // Currently touched bar index
                //       onTap: (i) => setState(() => touchedBar = i),  // Update touched bar index
                //       interval: interval,  // Current time interval
                //     ),
                //   ),
                // ),


                // 
              ],
            ),
          );
        },
      ),
    );
  }
}