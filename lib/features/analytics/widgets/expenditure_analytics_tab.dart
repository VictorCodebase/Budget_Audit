// lib/features/analytics/widgets/expenditure_analytics_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../analytics_viewmodel.dart';
import 'expenditure_chart_controls.dart';
import 'expenditure_vs_budget_chart.dart';
import 'spending_deep_dive_tab.dart';
import 'detailed_expenditure_tab.dart';

class ExpenditureAnalyticsTab extends StatelessWidget {
  const ExpenditureAnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();

    return Column(
      children: [
        // Chart controls
        ExpenditureChartControls(),
        const SizedBox(height: AppTheme.spacingSm),

        // Main expenditure vs budget chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: ExpenditureVsBudgetChart(),
        ),
        const SizedBox(height: AppTheme.spacingLg),

        // Sub-tab selector
        _buildSubTabSelector(context, viewModel),
        const SizedBox(height: AppTheme.spacingSm),

        // Sub-tab content
        viewModel.expenditureSubTab == ExpenditureSubTab.spendingDeepDive
            ? const SpendingDeepDiveTab()
            : const DetailedExpenditureTab(),
      ],
    );
  }

  Widget _buildSubTabSelector(
      BuildContext context, AnalyticsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSubTabButton(
              context,
              'Spending Deep Dive',
              ExpenditureSubTab.spendingDeepDive,
              viewModel.expenditureSubTab == ExpenditureSubTab.spendingDeepDive,
              () => viewModel
                  .setExpenditureSubTab(ExpenditureSubTab.spendingDeepDive),
            ),
          ),
          Expanded(
            child: _buildSubTabButton(
              context,
              'Detailed Analysis',
              ExpenditureSubTab.detailedExpenditure,
              viewModel.expenditureSubTab ==
                  ExpenditureSubTab.detailedExpenditure,
              () => viewModel
                  .setExpenditureSubTab(ExpenditureSubTab.detailedExpenditure),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(
    BuildContext context,
    String label,
    ExpenditureSubTab tab,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.button.copyWith(
            color: isSelected ? Colors.white : context.colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
