// lib/widgets/prob_bar.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProbBar extends StatelessWidget {
  final List<double> probs;         // örn: [0.7, 0.2, 0.1]
  final List<String> labels;        // örn: ["setosa","versicolor","virginica"]
  final double height;
  final bool showValues;            // çubuk üstünde değer yazsın mı?

  const ProbBar({
    super.key,
    required this.probs,
    required this.labels,
    this.height = 180,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal =
    (probs.isEmpty) ? 1.0 : probs.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: (maxVal <= 1.0) ? 1.0 : maxVal,
          gridData: FlGridData(show: true),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final i = group.x.toInt();
                final lbl = (i >= 0 && i < labels.length) ? labels[i] : '';
                return BarTooltipItem(
                  '$lbl\n${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 0.2,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  final i = val.toInt();
                  final text =
                  (i >= 0 && i < labels.length) ? labels[i] : '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(probs.length, (i) {
            final val = probs[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: val,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              showingTooltipIndicators: showValues ? [0] : const [],
            );
          }),
        ),
      ),
    );
  }
}
