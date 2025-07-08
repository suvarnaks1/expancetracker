// Bar Chart Widget
import 'dart:math';

import 'package:expance_tracker_app/resources/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> data;
  final int touchedIndex;
  final void Function(int) onTap;
  final String interval;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.touchedIndex,
    required this.onTap,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (data.isEmpty ? 0 : data.reduce(max)) * 1.2;
    return BarChart(BarChartData(
      maxY: maxY,
      barTouchData: BarTouchData(touchCallback: (_, resp) {
        final i = resp?.spot?.touchedBarGroupIndex;
        if (i != null && i >= 0 && i < data.length) onTap(i);
      }),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (val, meta) {
            final i = val.toInt();
            if (i < 0 || i >= data.length) return const SizedBox();
            String lbl;
            if (interval == 'Day') lbl = '${i}h';
            else if (interval == 'Week') {
              const wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              lbl = wk[i];
            } else {
              lbl = '${i + 1}';
            }
            return SideTitleWidget(
  meta: meta, // ✅ required
  space: 8.0,
  angle: 0.0, // optional, remove if not needed
  child: Text(lbl, style: TextStyle(color: AppColors.deepPink, fontSize: 10)),
);


          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(data.length, (i) {
        final isTouched = i == touchedIndex;
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: data[i],
            color: AppColors.mediumPink,
            width: isTouched ? 20 : 16,
            borderRadius: BorderRadius.circular(6),
          ),
        ]);
      }),
    ));
  }
}