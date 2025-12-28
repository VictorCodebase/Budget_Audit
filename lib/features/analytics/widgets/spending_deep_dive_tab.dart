// lib/features/analytics/widgets/spending_deep_dive_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../analytics_viewmodel.dart';

class SpendingDeepDiveTab extends StatelessWidget {
  const SpendingDeepDiveTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resource Allocation by Category',
            style: AppTheme.h3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          if (isWideScreen)
            _buildWideScreenLayout(context)
          else
            _buildNarrowScreenLayout(context),
          const SizedBox(height: AppTheme.spacingXl),
          _buildExpenditureRelativeToBudgetChart(context),
        ],
      ),
    );
  }

  Widget _buildWideScreenLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildCategorySpendingBarChart(context),
        ),
        const SizedBox(width: AppTheme.spacingLg),
        Expanded(
          flex: 5,
          child: _buildCategorySpendingPieChart(context),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(BuildContext context) {
    return Column(
      children: [
        _buildCategorySpendingPieChart(context),
        const SizedBox(height: AppTheme.spacingLg),
        _buildCategorySpendingBarChart(context),
      ],
    );
  }

  Widget _buildCategorySpendingPieChart(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();

    if (viewModel.categorySpendingData.isEmpty) {
      return _buildEmptyState(context, 'No spending data available');
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
          Text(
            'Spending by Category',
            style: AppTheme.h4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: _buildSpendingPieChartSections(context, viewModel),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (event is FlTapUpEvent &&
                        pieTouchResponse?.touchedSection != null) {
                      final index =
                          pieTouchResponse!.touchedSection!.touchedSectionIndex;
                      if (index >= 0 &&
                          index < viewModel.categorySpendingData.length) {
                        viewModel.selectCategoryForBarChart(
                          viewModel.categorySpendingData[index],
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _buildSpendingLegend(context, viewModel),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSpendingPieChartSections(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final totalSpent = viewModel.categorySpendingData.fold(
      0.0,
      (sum, data) => sum + data.spent,
    );

    return viewModel.categorySpendingData.map((data) {
      final isSelected =
          viewModel.selectedCategoryForBarChart?.category.categoryId ==
              data.category.categoryId;
      final percentage = totalSpent > 0 ? (data.spent / totalSpent) * 100 : 0;

      return PieChartSectionData(
        value: data.spent,
        title: '${percentage.toStringAsFixed(0)}%',
        color: data.category.color,
        radius: isSelected ? 70 : 60,
        titleStyle: AppTheme.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        badgeWidget: isSelected
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  formatter.format(data.spent),
                  style: AppTheme.caption.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildSpendingLegend(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return Wrap(
      spacing: AppTheme.spacingMd,
      runSpacing: AppTheme.spacingSm,
      children: viewModel.categorySpendingData.map((data) {
        return InkWell(
          onTap: () => viewModel.selectCategoryForBarChart(data),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacing2xs,
            ),
            decoration: BoxDecoration(
              color: data.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: viewModel
                            .selectedCategoryForBarChart?.category.categoryId ==
                        data.category.categoryId
                    ? data.category.color
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: data.category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2xs),
                Text(
                  data.category.categoryName,
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySpendingBarChart(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final selectedCategory = viewModel.selectedCategoryForBarChart;

    if (selectedCategory == null || selectedCategory.accounts.isEmpty) {
      return _buildEmptyState(
        context,
        'Select a category to view account spending',
      );
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
          Text(
            '${selectedCategory.category.categoryName} - Account Spending',
            style: AppTheme.h4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: selectedCategory.accounts
                        .map((a) => a.spent)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.colors.surfaceVariant,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final account = selectedCategory.accounts[group.x];
                      final formatter = NumberFormat.currency(
                        symbol: '\$',
                        decimalDigits: 2,
                      );
                      return BarTooltipItem(
                        '${account.account.accountName}\n',
                        AppTheme.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Spent: ${formatter.format(rod.toY)}\n',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Budget: ${formatter.format(account.budgeted)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= selectedCategory.accounts.length) {
                          return const SizedBox.shrink();
                        }
                        final account =
                            selectedCategory.accounts[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            account.account.accountName,
                            style: AppTheme.caption.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        final formatter = NumberFormat.compact();
                        return Text(
                          formatter.format(value),
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
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.colors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildSpendingBarGroups(selectedCategory),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildSpendingBarGroups(
      CategorySpendingData category) {
    return List.generate(
      category.accounts.length,
      (index) {
        final account = category.accounts[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: account.spent,
              color: account.account.color,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenditureRelativeToBudgetChart(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();

    if (viewModel.expenditureRelativeToBudgetData.isEmpty) {
      return _buildEmptyState(context, 'No expenditure data available');
    }

    final isStacked = viewModel.participantFilter == ParticipantFilter.all;

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
          Text(
            'Expenditure Relative to Budget',
            style: AppTheme.h3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2xs),
          Text(
            isStacked
                ? 'Stacked view showing all participants'
                : 'Individual participant view',
            style: AppTheme.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxYForRelativeBudget(viewModel),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.colors.surfaceVariant,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dataPoint =
                          viewModel.expenditureRelativeToBudgetData[group.x];
                      return BarTooltipItem(
                        '${dataPoint.label}\n',
                        AppTheme.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toStringAsFixed(1)}%',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >=
                                viewModel
                                    .expenditureRelativeToBudgetData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            viewModel
                                .expenditureRelativeToBudgetData[index].label,
                            style: AppTheme.caption.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      reservedSize: 40,
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
                borderData: FlBorderData(show: false),
                barGroups: _buildRelativeBudgetBarGroups(context, viewModel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildRelativeBudgetBarGroups(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return viewModel.expenditureRelativeToBudgetData
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final dataPoint = entry.value;

      if (viewModel.participantFilter == ParticipantFilter.all &&
          dataPoint.participantValues != null) {
        // Stacked bars
        final rodStackItems = <BarChartRodStackItem>[];
        double fromY = 0;

        dataPoint.participantValues!.forEach((participantId, value) {
          final toY = fromY + value;
          rodStackItems.add(
            BarChartRodStackItem(
              fromY,
              toY,
              context.colors.primary,
            ),
          );
          fromY = toY;
        });

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: dataPoint.value,
              color: context.colors.primary,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              rodStackItems: rodStackItems,
            ),
          ],
        );
      } else {
        // Single bar
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: dataPoint.value,
              color: context.colors.secondary,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }
    }).toList();
  }

  double _calculateMaxYForRelativeBudget(AnalyticsViewModel viewModel) {
    if (viewModel.expenditureRelativeToBudgetData.isEmpty) return 120;

    final maxValue = viewModel.expenditureRelativeToBudgetData
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b);

    return maxValue > 100 ? maxValue * 1.2 : 120;
  }

  Widget _buildEmptyState(BuildContext context, String message) {
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
              Icons.bar_chart,
              size: 64,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
