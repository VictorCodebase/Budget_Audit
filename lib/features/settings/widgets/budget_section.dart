import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/widgets/content_box.dart';
import 'package:budget_audit/features/settings/management_viewmodels/template_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/category_management_viewmodel.dart';
import 'package:budget_audit/features/settings/widgets/group_content_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Budget section showing groups with nested categories.
class BudgetSection extends StatelessWidget {
  const BudgetSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetViewModel = context.watch<TemplateManagementViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          budgetViewModel.isManager ? 'All Budgets' : 'My Budgets',
          style: AppTheme.h3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          budgetViewModel.isManager
              ? 'View and manage all budgets'
              : 'Your budgets',
          style: AppTheme.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (budgetViewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingXl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (budgetViewModel.templates.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Text(
                'No budgets found',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...budgetViewModel.templates.map((budget) {
            return _buildBudgetContentBox(
              context,
              budgetViewModel,
              budget,
            );
          }).toList(),
        if (budgetViewModel.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            child: Text(
              budgetViewModel.error!,
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBudgetContentBox(
    BuildContext context,
    TemplateManagementViewModel viewModel,
    dynamic budget,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: FutureBuilder<double>(
        future: viewModel.getTemplateTotalBudget(budget.templateId),
        builder: (context, snapshot) {
          final budgetAmount = snapshot.hasData
              ? '\$${snapshot.data!.toStringAsFixed(2)}'
              : '\$0.00';

          return ContentBox(
            minimizedHeight: 60,
            initiallyMinimized: true,
            expandContent: false,
            controls: [
              const ContentBoxControl(
                action: ContentBoxAction.minimize,
              ),
              ContentBoxControl(
                action: ContentBoxAction.delete,
                onPressed: () =>
                    _confirmDeleteTemplate(context, viewModel, budget),
              ),
            ],
            headerWidgets: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.templateName,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2xs),
                    Text(
                      'Total Budget: $budgetAmount',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            previewWidgets: [
              Text(
                budget.templateName,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                budgetAmount,
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                budget.period,
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Budget Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Period: ${budget.period}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            'Created: ${DateFormat('MMM d, yyyy').format(budget.dateCreated)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            'Times Used: ${budget.timesUsed}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Groups Section (v1 Categories)
                Text(
                  'Groups',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                _buildGroupsForBudget(context, budget.templateId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupsForBudget(BuildContext context, int budgetId) {
    final categoryViewModel = context.watch<CategoryManagementViewModel>();
    final categories = categoryViewModel.getCategoriesForTemplate(budgetId);
    final isLoading = categoryViewModel.isTemplateLoading(budgetId);
    final isLoaded = categoryViewModel.isTemplateLoaded(budgetId);

    // Initial load trigger
    if (!isLoaded && !isLoading) {
      // Use microtask to avoid build-phase updates
      Future.microtask(() {
        categoryViewModel.loadCategoriesForTemplate(budgetId);
      });
    }

    if (isLoading && categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isLoading && categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Text(
            'No groups in this budget',
            style: AppTheme.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: GroupContentBox(
            group: category,
            budgetId: budgetId,
          ),
        );
      }).toList(),
    );
  }

  void _confirmDeleteTemplate(
    BuildContext context,
    TemplateManagementViewModel viewModel,
    dynamic budget,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete "${budget.templateName}"?\n\n'
          'This will delete all groups and categories within this budget.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteTemplate(budget);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Budget deleted successfully'),
                    backgroundColor: context.colors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
