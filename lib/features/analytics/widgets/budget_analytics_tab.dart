// lib/features/analytics/widgets/budget_analytics_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../analytics_viewmodel.dart';

class BudgetAnalyticsTab extends StatelessWidget {
  const BudgetAnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalBudgetCard(context, viewModel),
          const SizedBox(height: AppTheme.spacingLg),
          if (isWideScreen)
            _buildWideScreenLayout(context, viewModel)
          else
            _buildNarrowScreenLayout(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildTotalBudgetCard(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Budgeted',
            style: AppTheme.label.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTheme.spacing2xs),
          Text(
            formatter.format(viewModel.totalBudgeted),
            style: AppTheme.h1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2xs),
          Text(
            viewModel.selectedTemplate?.period ?? '',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideScreenLayout(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildCategoryPieChart(context, viewModel),
        ),
        const SizedBox(width: AppTheme.spacingLg),
        Expanded(
          flex: 5,
          child: _buildAccountBarChart(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return Column(
      children: [
        _buildCategoryPieChart(context, viewModel),
        const SizedBox(height: AppTheme.spacingLg),
        _buildAccountBarChart(context, viewModel),
      ],
    );
  }

  Widget _buildCategoryPieChart(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    if (viewModel.categorySpendingData.isEmpty) {
      return _buildEmptyState(context, 'No budget data available');
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
            'Budget by Category',
            style: AppTheme.h3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(context, viewModel),
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
          _buildPieChartLegend(context, viewModel),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return viewModel.categorySpendingData.map((data) {
      final isSelected =
          viewModel.selectedCategoryForBarChart?.category.categoryId ==
              data.category.categoryId;

      return PieChartSectionData(
        value: data.budgeted,
        title: '${data.percentage.toStringAsFixed(0)}%',
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
                  formatter.format(data.budgeted),
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

  Widget _buildPieChartLegend(
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

  Widget _buildAccountBarChart(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    final selectedCategory = viewModel.selectedCategoryForBarChart;

    if (selectedCategory == null || selectedCategory.accounts.isEmpty) {
      return _buildEmptyState(
        context,
        'Select a category to view accounts',
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
            selectedCategory.category.categoryName,
            style: AppTheme.h3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2xs),
          Text(
            'Account Breakdown',
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
                maxY: selectedCategory.accounts
                        .map((a) => a.budgeted)
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
                            text: formatter.format(rod.toY),
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
                  horizontalInterval: null,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.colors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(selectedCategory),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(CategorySpendingData category) {
    return List.generate(
      category.accounts.length,
      (index) {
        final account = category.accounts[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: account.budgeted,
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
              Icons.pie_chart_outline,
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
