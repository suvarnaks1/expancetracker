import 'package:expance_tracker_app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseMonthView extends StatefulWidget {
  const ExpenseMonthView({super.key});
  @override
  State<ExpenseMonthView> createState() => _ExpenseMonthViewState();
}

class _ExpenseMonthViewState extends State<ExpenseMonthView> {
  String activeTab = 'Shopping';
  final List<String> tabs = ['All', 'Food', 'Shopping', 'Transport',];

  // Sample data (replace with your actual data)
  final Map<String, double> categorySpending = {
    'Food': 400,
    'Shopping': 250,
    'Transport': 150,
    'Other': 100
  };
  final List<double> monthlyTotals = [100, 140, 80, 160];

  int touchedPieIndex = -1;
  int touchedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink1,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back_ios, color: AppColors.deepPink),
                    const Text('Expense',
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Icon(Icons.calendar_today, color: AppColors.deepPink),
                  ],
                ),
                const SizedBox(height: 16),
        
                // Time-range chips
                Row(
                  children: ['Day', 'Week', 'Month']
                      .map((label) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label,
                                  style: TextStyle(
                                      color: label == 'Month'
                                          ? Colors.white
                                          : AppColors.deepPink)),
                              selected: label == 'Month',
                              selectedColor: AppColors.deepPink,
                              backgroundColor: AppColors.lightPink2,
                              onSelected: (_) {},
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
        
                // Pie chart
                Text('Spending by Category',
                    style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 200, child: buildPieChart()),
        
                const SizedBox(height: 24),
        
                // Bar chart
                Text('Monthly Trend',
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 200, child: buildBarChart()),
        
                const SizedBox(height: 24),
        
                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tabs.map((tab) {
                      final selected = tab == activeTab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(tab),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => activeTab = tab),
                          selectedColor: AppColors.deepPink,
                          backgroundColor: AppColors.lightPink2,
                          labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : AppColors.deepPink),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        
                const SizedBox(height: 16),
        
                // Example transaction card
                _buildTransactionCard(
                  'Shoes',
                  'Sneakers',
                  '-\$40.00',
                  'Aug 26',
                  AppColors.lightPink2,
                  Icons.shopping_bag,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPieChart() {
    final total = categorySpending.values.fold<double>(0, (sum, e) => sum + e);
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (event, resp) {
            setState(() {
              touchedPieIndex = resp?.touchedSection?.touchedSectionIndex ?? -1;
            });
          },
        ),
        sections: List.generate(categorySpending.length, (i) {
          final entry = categorySpending.entries.elementAt(i);
          final isTouched = i == touchedPieIndex;
          final value = entry.value;
          final percent = (value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            color: _getColorForCategory(entry.key),
            value: value,
            title: '$percent%',
            radius: isTouched ? 70 : 60,
            titleStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }

  Widget buildBarChart() {
    return BarChart(
      BarChartData(
        maxY: (monthlyTotals.reduce((a, b) => a > b ? a : b)) * 1.2,
        barTouchData: BarTouchData(
          touchCallback: (event, resp) {
            setState(() {
              touchedBarIndex = resp?.spot?.touchedBarGroupIndex ?? -1;
            });
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const labels = ['Jun', 'Jul', 'Aug', 'Sep'];
                final idx = value.toInt().clamp(0, labels.length - 1);
                return Text(labels[idx],
                    style: TextStyle(color: AppColors.deepPink));
              },
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(monthlyTotals.length, (i) {
          final y = monthlyTotals[i];
          final isTouched = i == touchedBarIndex;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: y,
              color: AppColors.mediumPink,
              width: isTouched ? 20 : 16,
              borderRadius: BorderRadius.circular(6),
            ),
          ]);
        }),
      ),
    );
  }

  Color _getColorForCategory(String cat) {
    switch (cat) {
      case 'Food':
        return Colors.green;
      case 'Shopping':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTransactionCard(
      String title, String subtitle, String amount, String date, Color bg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, color: AppColors.deepPink)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ],
      ),
    );
  }
}
