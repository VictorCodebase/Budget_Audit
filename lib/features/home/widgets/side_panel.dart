import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';
import '../home_viewmodel.dart';
import 'read_only_category_widget.dart';
import '../../../core/context.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Budget actions (deactivated for now)
          // _buildTemplateActionsSection(),
          // const SizedBox(height: AppTheme.spacingXl),

          // Budget history
          _buildTemplateHistorySection(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildTemplateActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionButton(
          context: context,
          label: 'Download your current budget',
          buttonLabel: 'Download budget',
          onPressed: () {
            // TODO: Implement download template
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildActionButton(
          context: context,
          label: 'Download your current budget',
          buttonLabel: 'Download Budget',
          onPressed: () {
            // TODO: Implement download budget
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildActionButton(
          context: context,
          label: 'Open your current template',
          buttonLabel: 'Open Budget',
          onPressed: () {
            // TODO: Implement open budget
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildActionButton(
          context: context,
          label: 'Open your current budget',
          buttonLabel: 'Open Budget',
          onPressed: () {
            // TODO: Implement open budget
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.surface,
            foregroundColor: context.colors.textPrimary,
            elevation: 0,
            side: BorderSide(color: context.colors.border, width: 1),
            minimumSize: const Size(double.infinity, 40),
          ),
          child: Text(buttonLabel),
        ),
      ],
    );
  }

  Widget _buildTemplateHistorySection(
      BuildContext context, HomeViewModel viewModel) {
    // Take at most 6 latest templates
    final templates = viewModel.templateHistory.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget History',
          style: AppTheme.h4,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (templates.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(
                'No Budgets yet',
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...templates.map((template) {
            return _buildTemplateContentBox(context, viewModel, template);
          }).toList(),
      ],
    );
  }

  Widget _buildTemplateContentBox(
    BuildContext context,
    HomeViewModel viewModel,
    template,
  ) {
    // Determine if current
    final isCurrent =
        viewModel.currentTemplate?.templateId == template.templateId;

    return FutureBuilder<double>(
      future: viewModel.getTemplateTotalBudget(template.templateId),
      builder: (context, snapshot) {
        final budgetAmount = snapshot.hasData
            ? '\$${snapshot.data!.toStringAsFixed(2)}'
            : '\$0.00';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: ContentBox(
            minimizedHeight: 60,
            initiallyMinimized: true,
            expandContent: true,
            controls: [
              ContentBoxControl(
                action: ContentBoxAction.preview,
                onPressed: () => _showPreview(context, viewModel, template),
              ),
              // const ContentBoxControl(
              //   action: ContentBoxAction.minimize,
              // ),
              if (!isCurrent)
                ContentBoxControl(
                  action: ContentBoxAction.delete,
                  onPressed: () =>
                      _confirmDeleteTemplate(context, viewModel, template),
                ),
            ],
            headerWidgets: [
              Flexible(
                  child: Text(template.templateName,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      )))
            ],
            previewWidgets: [
              // Template Name
              Text(
                template.templateName,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              // Budget Amount or Current Status
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current',
                    style: AppTheme.caption.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  budgetAmount,
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Added Total Budget display here
                Text(
                  'Total Budget: $budgetAmount',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(template.dateCreated)}',
                  style: AppTheme.bodySmall
                      .copyWith(color: context.colors.textSecondary),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                // Adopt button only if not current
                if (!isCurrent)
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement adopt template
                      Provider.of<AppContext>(context, listen: false)
                          .setCurrentTemplate(template);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                      foregroundColor: context.colors.textPrimary,
                    ),
                    child: const Text('Adopt Budget'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPreview(BuildContext context, HomeViewModel viewModel, template) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preview: ${template.templateName}',
                      style: AppTheme.h3,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: FutureBuilder(
                  future: viewModel.getTemplateDetails(template.templateId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading template details',
                          style: AppTheme.bodyMedium
                              .copyWith(color: context.colors.error),
                        ),
                      );
                    }

                    final categories = snapshot.data as List;

                    if (categories.isEmpty) {
                      return const Center(
                          child: Text('No categories in this Budget'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppTheme.spacingMd),
                      itemBuilder: (context, index) {
                        return ReadOnlyCategoryWidget(
                            category: categories[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTemplate(
      BuildContext context, HomeViewModel viewModel, template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content:
            Text('Are you sure you want to delete "${template.templateName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTemplate(template.templateId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
