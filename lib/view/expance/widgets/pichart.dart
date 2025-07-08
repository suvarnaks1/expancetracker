import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final int touchedIndex;
  final void Function(int) onTap;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.touchedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      pieTouchData: PieTouchData(touchCallback: (_, resp) {
        onTap(resp?.touchedSection?.touchedSectionIndex ?? -1);
      }),
      sections: List.generate(data.length, (i) {
        final e = data.entries.elementAt(i);
        final isTouched = i == touchedIndex;
        final pct = total == 0 ? '0%' : '${(e.value / total * 100).toStringAsFixed(1)}%';
        return PieChartSectionData(
          color: _colorFor(e.key),
          value: e.value,
          title: pct,
          radius: isTouched ? 70 : 60,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }),
    ));
  }

  Color _colorFor(String cat) => {
        'Food': Colors.green,
        'Shopping': Colors.orange,
        'Transport': Colors.blue,
      }[cat] ??
      Colors.grey;
}