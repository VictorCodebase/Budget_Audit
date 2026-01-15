// lib/features/analytics/widgets/expenditure_vs_budget_chart.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../analytics_viewmodel.dart';

class ExpenditureVsBudgetChart extends StatelessWidget {
  const ExpenditureVsBudgetChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();

    if (viewModel.expenditureVsBudgetData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expenditure vs Budget',
                      style: AppTheme.h3.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2xs),
                    Text(
                      'Percentage of budget spent over time',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLegend(context),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  _buildExpenditureLine(context, viewModel),
                  _buildBudgetLine(context),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= viewModel.expenditureVsBudgetData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            viewModel.expenditureVsBudgetData[index].label,
                            style: AppTheme.caption.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: AppTheme.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: value == 100
                          ? context.colors.warning
                          : context.colors.border,
                      strokeWidth: value == 100 ? 2 : 1,
                      dashArray: value == 100 ? [5, 5] : null,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: context.colors.border),
                    bottom: BorderSide(color: context.colors.border),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => context.colors.surfaceVariant,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}%',
                          AppTheme.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                minY: 0,
                maxY: _calculateMaxY(viewModel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildExpenditureLine(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return LineChartBarData(
      spots: viewModel.expenditureVsBudgetData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.value);
      }).toList(),
      isCurved: true,
      color: context.colors.primary,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: context.colors.primary,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.primary.withOpacity(0.2),
            context.colors.primary.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildBudgetLine(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final maxX = viewModel.expenditureVsBudgetData.isEmpty
        ? 0.0
        : (viewModel.expenditureVsBudgetData.length - 1).toDouble();

    return LineChartBarData(
      spots: [
        const FlSpot(0, 100),
        FlSpot(maxX, 100),
      ],
      isCurved: false,
      color: context.colors.warning,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      dashArray: [5, 5],
    );
  }

  double _calculateMaxY(AnalyticsViewModel viewModel) {
    if (viewModel.expenditureVsBudgetData.isEmpty) return 120;

    final maxValue = viewModel.expenditureVsBudgetData
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b);

    // Ensure we show at least up to 120%
    return maxValue > 100 ? maxValue * 1.2 : 120;
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(
          context,
          'Spending',
          context.colors.primary,
          false,
        ),
        const SizedBox(height: AppTheme.spacing2xs),
        _buildLegendItem(
          context,
          'Budget Line',
          context.colors.warning,
          true,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    bool isDashed,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: color, width: 2) : null,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: AppTheme.spacing2xs),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: context.colors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No expenditure data available',
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
