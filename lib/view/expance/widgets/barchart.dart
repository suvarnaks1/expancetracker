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

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchCallback: (_, resp) {
            final i = resp?.spot?.touchedBarGroupIndex;
            if (i != null && i >= 0 && i < data.length) onTap(i);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),  //  Removed top line
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Removed right line
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();

                String lbl;
                if (interval == 'Day') {
                  lbl = '${i}h';
                } else if (interval == 'Week') {
                  const wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  lbl = wk[i];
                } else if (interval == 'Month') {
                  if ((i + 1) % 5 != 0 && i != data.length - 1) return const SizedBox();
                  lbl = '${i + 1}';
                } else {
                  lbl = '${i + 1}';
                }

                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  child: Text(
                    lbl,
                    style: const TextStyle(color: AppColors.deepPink, fontSize: 10),
                  ),
                );
              },
            ),
          ),
         leftTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 40,
    getTitlesWidget: (value, meta) {
      final y = value.toInt();
      if (y % 10 != 0) return const SizedBox(); // Only multiples of 10
      return Text(
        y.toString(),
        style: const TextStyle(fontSize: 10, color: AppColors.deepPink),
      );
    },
  ),
),

        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          final isTouched = i == touchedIndex;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: AppColors.mediumPink,
                width: isTouched ? 20 : 16,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}
