import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Small line chart (sparkline) for crypto cards and list items.
class SparklineChart extends StatelessWidget {
  final List<double> data;
  final bool isPositive;
  final double width;
  final double height;

  const SparklineChart({
    super.key,
    required this.data,
    required this.isPositive,
    this.width = 80,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(0.01, double.infinity);
    final spots = data.asMap().entries.map((e) {
      final x = (e.key / (data.length - 1).clamp(1, data.length)) * (data.length - 1);
      final y = (e.value - min) / range;
      return FlSpot(x.toDouble(), y);
    }).toList();

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: 1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.2),
                    (isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 150),
      ),
    );
  }
}
