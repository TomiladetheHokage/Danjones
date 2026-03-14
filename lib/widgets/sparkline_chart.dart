import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
    if (data == null || data!.length < 2) return const SizedBox();

    // 1. DATA OPTIMIZATION
    final rawData = data!;
    List<double> processedData = [];
    int pointsCount = 40; 
    
    double step = rawData.length / pointsCount;
    for (int i = 0; i < pointsCount; i++) {
      processedData.add(rawData[(i * step).toInt()]);
    }

    // 2. NORMALIZATION
    final min = processedData.reduce((a, b) => a < b ? a : b);
    final max = processedData.reduce((a, b) => a > b ? a : b);
    final range = (max - min) <= 0 ? 1.0 : (max - min);

    final spots = processedData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value - min) / range);
    }).toList();

    final chartColor = isPositive ? const Color(0xFF5ED5A8) : const Color(0xFFEF4444);

    return SizedBox(
      width: width ?? 60,
      height: height ?? 30,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: -0.05,
          maxY: 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35, 
              preventCurveOverShooting: false, 
              color: chartColor,
              // --- THINNER LINE ---
              barWidth: 1.2, 
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              
              // --- SUBTLE GLOW ---
              shadow: Shadow(
                blurRadius: 6, // Reduced from 10
                color: chartColor.withOpacity(0.3), // Reduced from 0.5
                offset: const Offset(0, 0),
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    chartColor.withOpacity(0.15), // Very light fill
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