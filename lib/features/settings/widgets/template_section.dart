import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/widgets/content_box.dart';
import 'package:budget_audit/features/settings/management_viewmodels/template_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/category_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/account_management_viewmodel.dart';
import 'package:budget_audit/features/settings/widgets/category_content_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Template section showing templates with nested categories and accounts
class TemplateSection extends StatelessWidget {
  const TemplateSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final templateViewModel = context.watch<TemplateManagementViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          templateViewModel.isManager ? 'All Templates' : 'My Templates',
          style: AppTheme.h3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          templateViewModel.isManager
              ? 'View and manage all budget templates'
              : 'Templates you are part of',
          style: AppTheme.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (templateViewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingXl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (templateViewModel.templates.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Text(
                'No templates found',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...templateViewModel.templates.map((template) {
            return _buildTemplateContentBox(
              context,
              templateViewModel,
              template,
            );
          }).toList(),
        if (templateViewModel.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            child: Text(
              templateViewModel.error!,
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTemplateContentBox(
    BuildContext context,
    TemplateManagementViewModel viewModel,
    dynamic template,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          viewModel.getTemplateTotalBudget(template.templateId),
          viewModel.getTemplateParticipants(template.templateId),
          viewModel.getCreatorName(template.creatorParticipantId),
        ]),
        builder: (context, snapshot) {
          final budgetAmount = snapshot.hasData
              ? '\$${(snapshot.data![0] as double).toStringAsFixed(2)}'
              : '\$0.00';
          final participants =
              snapshot.hasData ? snapshot.data![1] as List : [];
          final creatorName =
              snapshot.hasData ? snapshot.data![2] as String? : null;

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
                    _confirmDeleteTemplate(context, viewModel, template),
              ),
            ],
            headerWidgets: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.templateName,
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
              if (creatorName != null)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator',
                        style: AppTheme.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        creatorName,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            previewWidgets: [
              Text(
                template.templateName,
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
                '${participants.length} ${participants.length == 1 ? 'member' : 'members'}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                template.period,
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Template Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Period: ${template.period}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            'Created: ${DateFormat('MMM d, yyyy').format(template.dateCreated)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Text(
                            'Times Used: ${template.timesUsed}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (participants.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Participants:',
                              style: AppTheme.caption.copyWith(
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing2xs),
                            ...participants.take(3).map((p) => Text(
                                  '• ${p.nickname ?? p.firstName}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                )),
                            if (participants.length > 3)
                              Text(
                                '  +${participants.length - 3} more',
                                style: AppTheme.caption.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Categories Section
                Text(
                  'Categories',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                _buildCategoriesForTemplate(context, template.templateId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesForTemplate(BuildContext context, int templateId) {
    final categoryViewModel = context.watch<CategoryManagementViewModel>();
    final categories = categoryViewModel.getCategoriesForTemplate(templateId);
    final isLoading = categoryViewModel.isTemplateLoading(templateId);
    final isLoaded = categoryViewModel.isTemplateLoaded(templateId);

    // Initial load trigger
    if (!isLoaded && !isLoading) {
      // Use microtask to avoid build-phase updates
      Future.microtask(() {
        categoryViewModel.loadCategoriesForTemplate(templateId);
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
            'No categories in this template',
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
          child: CategoryContentBox(
            category: category,
            templateId: templateId,
          ),
        );
      }).toList(),
    );
  }

  void _confirmDeleteTemplate(
    BuildContext context,
    TemplateManagementViewModel viewModel,
    dynamic template,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${template.templateName}"?\n\n'
          'This will delete all categories and accounts within this template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteTemplate(template);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Template deleted successfully'),
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
