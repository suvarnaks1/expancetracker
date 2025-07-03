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
  final List<String> tabs = ['All', 'Food', 'Shopping', 'Transport'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios, color: AppColors.deepPink),
                  const Text('Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Icon(Icons.calendar_today, color: AppColors.deepPink),
                ],
              ),
              const SizedBox(height: 16),

              // Day/Week/Month chips + calendar icon properly added
              Row(
                children: [
                  for (var label in ['Day', 'Week', 'Month'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          label,
                          style: TextStyle(color: label == 'Month' ? Colors.white : AppColors.deepPink),
                        ),
                        backgroundColor: label == 'Month' ? AppColors.deepPink : AppColors.lightPink2,
                      ),
                    ),
                  // Properly add the calendar icon without wrong cast
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: AppColors.deepPink),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Line chart
              AspectRatio(
                aspectRatio: 1.7,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const labels = ['Jun', 'Jul', 'Aug', 'Sep'];
                            final idx = v.toInt().clamp(0, 3);
                            return Text(labels[idx], style: TextStyle(color: AppColors.deepPink));
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 100),
                          FlSpot(1, 140),
                          FlSpot(2, 80),
                          FlSpot(3, 160),
                        ],
                        isCurved: true,
                        color: AppColors.mediumPink,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('-\$710.00', style: TextStyle(color: AppColors.deepPink, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),

              // Category choice chips
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
                        onSelected: (_) => setState(() => activeTab = tab),
                        selectedColor: AppColors.deepPink,
                        backgroundColor: AppColors.lightPink2,
                        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.deepPink),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Single transaction card
              _buildTransactionCard(
                'Shoes', 'Sneakers', '-\$40.00', 'Aug 26',
                AppColors.lightPink2, Icons.shopping_bag,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(String title, String subtitle, String amount, String date, Color bg, IconData icon) {
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
