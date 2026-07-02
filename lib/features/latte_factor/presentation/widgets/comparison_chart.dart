import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/formatters.dart';
import '../../../../core/theme.dart';

/// 원금(안 쓰고 모으기만 한 돈)과 복리 미래가치를 나란히 비교하는 막대 차트.
class ComparisonChart extends StatelessWidget {
  const ComparisonChart({
    super.key,
    required this.principal,
    required this.futureValue,
  });

  final double principal;
  final double futureValue;

  @override
  Widget build(BuildContext context) {
    final maxY = (futureValue <= 0 ? 1.0 : futureValue) * 1.25;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: maxY,
              barTouchData: BarTouchData(enabled: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
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
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      const labels = ['모으기만 하면', '복리로 굴리면'];
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[i],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                _rod(0, principal, kPrincipalColor, maxY),
                _rod(1, futureValue, kGrowthColor, maxY),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _amountLabel(context, kPrincipalColor, principal),
            _amountLabel(context, kGrowthColor, futureValue),
          ],
        ),
      ],
    );
  }

  BarChartGroupData _rod(int x, double value, Color color, double maxY) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 48,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: color.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }

  Widget _amountLabel(BuildContext context, Color color, double value) {
    return Column(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 4),
        Text(
          formatWonCompact(value),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
