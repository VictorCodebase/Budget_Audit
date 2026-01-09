// lib/features/analytics/widgets/detailed_expenditure_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';
import '../analytics_viewmodel.dart';

class DetailedExpenditureTab extends StatelessWidget {
  const DetailedExpenditureTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryList(context),
          const SizedBox(height: AppTheme.spacingXl),
          _buildAccountList(context),
          const SizedBox(height: AppTheme.spacingXl),
          _buildVendorList(context),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();

    // Sort categories by percentage of budget used
    final sortedCategories = List<CategorySpendingData>.from(
      viewModel.categorySpendingData,
    )..sort((a, b) => b.percentageOfBudget.compareTo(a.percentageOfBudget));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories by Budget Usage',
          style: AppTheme.h3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (sortedCategories.isEmpty)
          _buildEmptyState(context, 'No categories available')
        else
          ...sortedCategories.map((categoryData) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: _buildCategoryContentBox(context, categoryData),
            );
          }),
      ],
    );
  }

  Widget _buildCategoryContentBox(
    BuildContext context,
    CategorySpendingData categoryData,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return ContentBox(
      initiallyMinimized: true,
      controls: [
        ContentBoxControl(
          action: ContentBoxAction.minimize,
        ),
      ],
      previewWidgets: [
        _buildInfoColumn(
          context,
          'Category',
          categoryData.category.categoryName,
          categoryData.category.color,
        ),
        _buildInfoColumn(
          context,
          'Spent',
          formatter.format(categoryData.spent),
          null,
        ),
        _buildInfoColumn(
          context,
          'Budget',
          formatter.format(categoryData.budgeted),
          null,
        ),
        _buildInfoColumn(
          context,
          'Usage',
          '${categoryData.percentageOfBudget.toStringAsFixed(1)}%',
          _getUsageColor(context, categoryData.percentageOfBudget),
        ),
      ],
      headerWidgets: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: categoryData.category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              categoryData.category.categoryName,
              style: AppTheme.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: categoryData.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: categoryData.category.color.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  'Total Spent',
                  formatter.format(categoryData.spent),
                ),
                _buildSummaryItem(
                  context,
                  'Budget',
                  formatter.format(categoryData.budgeted),
                ),
                _buildSummaryItem(
                  context,
                  'Usage',
                  '${categoryData.percentageOfBudget.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          // Accounts list
          Text(
            'Accounts',
            style: AppTheme.h4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ...categoryData.accounts.map((accountData) {
            return _buildAccountItem(context, accountData);
          }),
        ],
      ),
    );
  }

  Widget _buildAccountItem(
      BuildContext context, AccountSpendingData accountData) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accountData.account.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            flex: 3,
            child: Text(
              accountData.account.accountName,
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formatter.format(accountData.spent),
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              formatter.format(accountData.budgeted),
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textTertiary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacing2xs,
            ),
            decoration: BoxDecoration(
              color: _getUsageColor(context, accountData.percentageOfBudget)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              '${accountData.percentageOfBudget.toStringAsFixed(0)}%',
              style: AppTheme.bodySmall.copyWith(
                color: _getUsageColor(context, accountData.percentageOfBudget),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Accounts by Budget Usage',
          style: AppTheme.h3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (viewModel.accountSpendingData.isEmpty)
          _buildEmptyState(context, 'No accounts available')
        else
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXl),
                      topRight: Radius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Account',
                          style: AppTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Spent',
                          style: AppTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          'Budget',
                          style: AppTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Usage',
                          style: AppTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                // Account rows
                ...viewModel.accountSpendingData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final accountData = entry.value;
                  final isLast =
                      index == viewModel.accountSpendingData.length - 1;

                  return Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: isLast
                            ? BorderSide.none
                            : BorderSide(color: context.colors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: accountData.account.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          flex: 3,
                          child: Text(
                            accountData.account.accountName,
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatter.format(accountData.spent),
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: Text(
                            formatter.format(accountData.budgeted),
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textTertiary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        SizedBox(
                          width: 60,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: AppTheme.spacing2xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getUsageColor(
                                      context, accountData.percentageOfBudget)
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              '${accountData.percentageOfBudget.toStringAsFixed(0)}%',
                              style: AppTheme.bodySmall.copyWith(
                                color: _getUsageColor(
                                    context, accountData.percentageOfBudget),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVendorList(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendors by Total Spending',
          style: AppTheme.h3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (viewModel.vendorSpendingData.isEmpty)
          _buildEmptyState(context, 'No vendor data available')
        else
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXl),
                      topRight: Radius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Vendor',
                          style: AppTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          'Total Spent',
                          style: AppTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Vendor rows
                ...viewModel.vendorSpendingData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final vendorData = entry.value;
                  final isLast =
                      index == viewModel.vendorSpendingData.length - 1;

                  return Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: isLast
                            ? BorderSide.none
                            : BorderSide(color: context.colors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendorData.vendor.vendorName,
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            formatter.format(vendorData.totalSpent),
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: context.colors.textTertiary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: valueColor ?? context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2xs),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getUsageColor(BuildContext context, double percentage) {
    if (percentage >= 100) return context.colors.error;
    if (percentage >= 80) return context.colors.warning;
    if (percentage >= 60) return context.colors.info;
    return context.colors.success;
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
              Icons.list_alt,
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
