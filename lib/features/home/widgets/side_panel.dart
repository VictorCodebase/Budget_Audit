import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';
import '../home_viewmodel.dart';
import 'read_only_category_widget.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Participants Section
          _buildParticipantsSection(viewModel),
          const SizedBox(height: AppTheme.spacingXl),

          // Template Actions Section
          _buildTemplateActionsSection(),
          const SizedBox(height: AppTheme.spacingXl),

          // Template History Section
          _buildTemplateHistorySection(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants',
          style: AppTheme.h4,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ...viewModel.participants.map((participant) {
          final initials = (participant.nickname ?? participant.firstName)
              .substring(0, 2)
              .toUpperCase();
          final isCurrentUser =
              participant.participantId == viewModel.currentParticipantId;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCurrentUser
                      ? AppTheme.primaryPink
                      : AppTheme.primaryBlue,
                  radius: 20,
                  child: Text(
                    initials,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.nickname ?? participant.firstName,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        participant.email,
                        style: AppTheme.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: Text(
                      'You',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: AppTheme.spacingSm),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Add participant functionality
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add participant'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
            side: BorderSide(color: AppTheme.primaryBlue, width: 1),
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionButton(
          label: 'Download your current template',
          buttonLabel: 'Download Template',
          onPressed: () {
            // TODO: Implement download template
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildActionButton(
          label: 'Download your current budget',
          buttonLabel: 'Download Budget',
          onPressed: () {
            // TODO: Implement download budget
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildActionButton(
          label: 'Open your current template',
          buttonLabel: 'Open Template',
          onPressed: () {
            // TODO: Implement open template
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildActionButton(
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
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surface,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
            side: BorderSide(color: AppTheme.border, width: 1),
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
        Text(
          'Template History',
          style: AppTheme.h4,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (templates.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Text(
                'No templates yet',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
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
    // TODO: Get actual budget amount if available in template model or fetch it
    // For now using a placeholder or 0 if not available
    final budgetAmount = '\$0.00';
    final isCurrent = false; // TODO: Determine if current

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: ContentBox(
        minimizedHeight: 60,
        initiallyMinimized: true,
        controls: [
          ContentBoxControl(
            action: ContentBoxAction.preview,
            onPressed: () => _showPreview(context, viewModel, template),
          ),
          ContentBoxControl(
            action: ContentBoxAction.minimize,
            // ContentBox handles toggle internally if we don't override onPressed,
            // but we want to be explicit or let it handle it.
            // If we pass onPressed, we might need to manage state.
            // ContentBox default behavior for minimize/maximize is good.
            // But we need to pass it to show the icon.
          ),
          ContentBoxControl(
            action: ContentBoxAction.delete,
            onPressed: () =>
                _confirmDeleteTemplate(context, viewModel, template),
          ),
        ],
        previewWidgets: [
          // Template Name
          Flexible(
            child: Text(
              template.templateName,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Budget Amount or Current Status
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Current',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              budgetAmount,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Created: ${DateFormat('MMM d, yyyy').format(template.dateCreated)}',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement adopt template
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Adopt Template'),
            ),
          ],
        ),
      ),
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
            color: AppTheme.backgroundColor,
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
                              .copyWith(color: AppTheme.error),
                        ),
                      );
                    }

                    final categories = snapshot.data as List;

                    if (categories.isEmpty) {
                      return const Center(
                          child: Text('No categories in this template'));
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
        title: const Text('Delete Template'),
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
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
