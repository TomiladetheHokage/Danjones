import 'package:flutter/material.dart'; // This provides BuildContext, SizedBox, etc.
import 'package:fl_chart/fl_chart.dart'; // This provides LineChart, FlSpot, etc.

class SparklineChart extends StatelessWidget {
  final List<double>? data;
  final bool isPositive;
  final double? width;
  final double? height;

  const SparklineChart({
    super.key,
    this.data,
    required this.isPositive,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // If data is null or empty, return an empty box to prevent crashes
    if (data == null || data!.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    final nonNullData = data!;
    final min = nonNullData.reduce((a, b) => a < b ? a : b);
    final max = nonNullData.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(0.01, double.infinity);

    final spots = nonNullData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value - min) / range);
    }).toList();

    // Use your brand color #5ED5A8
    const brandColor = Color(0xFF5ED5A8);
    final chartColor = isPositive ? brandColor : const Color(0xFFEF4444);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 45,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minX: 0,
          maxX: (nonNullData.length - 1).toDouble(),
          minY: -0.05,
          maxY: 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.05, // Ultra-spiky for 500 points
              color: chartColor,
              barWidth: 1.2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    chartColor.withOpacity(0.2),
                    chartColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}