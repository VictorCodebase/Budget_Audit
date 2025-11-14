import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/modal_box.dart';
import '../../core/context.dart';
import '../../core/models/models.dart' as models;
import 'budgeting_viewmodel.dart';
import 'widgets/import_option_card.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_widget.dart';
import 'widgets/template_history_item.dart';

class BudgetingView extends StatefulWidget {
  const BudgetingView({Key? key}) : super(key: key);

  @override
  State<BudgetingView> createState() => _BudgetingViewState();
}

class _BudgetingViewState extends State<BudgetingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetingViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<BudgetingViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                const AppHeader(
                  subtitle: 'Create and manage your budget templates',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainContainer(context, viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContainer(BuildContext context, BudgetingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with underline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a Budget Template to start',
                style: AppTheme.h2,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Container(
                height: 3,
                width: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXl),

          // Import options
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // Stack vertically on mobile
                return Column(
                  children: [
                    const ImportOptionCard(
                      title: 'Import a default budget template',
                      description: 'A template designed for two individuals',
                      isEnabled: false,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    const ImportOptionCard(
                      title: 'Import a custom budget template',
                      description: 'Learn about accepted formats here',
                      isEnabled: false,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ImportOptionCard(
                      title: 'Import a previous template',
                      description: 'This explores your previous templates',
                      onTap: () => _showTemplateHistory(context, viewModel),
                    ),
                  ],
                );
              }

              // Display in row on larger screens
              return Row(
                children: [
                  const Expanded(
                    child: ImportOptionCard(
                      title: 'Import a default budget template',
                      description: 'A template designed for two individuals',
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  const Expanded(
                    child: ImportOptionCard(
                      title: 'Import a custom budget template',
                      description: 'Learn about accepted formats here',
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: ImportOptionCard(
                      title: 'Import a previous template',
                      description: 'This explores your previous templates',
                      onTap: () => _showTemplateHistory(context, viewModel),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppTheme.spacing2xl),

          // Learn about budgeting link
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _launchBudgetingGuide(),
                icon: const Icon(Icons.help_outline, size: 16),
                label: Text(
                  'Learn how budgeting works in the Budget Audit',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryPink,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Search and filter
          const SearchFilterBar(),

          const SizedBox(height: AppTheme.spacingXl),

          // Categories
          if (viewModel.categories.isEmpty)
            _buildEmptyState()
          else
            ...viewModel.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: CategoryWidget(category: category),
              );
            }),

          const SizedBox(height: AppTheme.spacingMd),

          // Add category button
          InkWell(
            onTap: () => viewModel.addCategory(),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryPink,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryPink,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    'Add Category',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing2xl),

          // Save/Update buttons
          _buildActionButtons(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing2xl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.category_outlined,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No categories yet',
            style: AppTheme.h3.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Add your first category to start building your budget',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BudgetingViewModel viewModel) {
    final validationMessage = viewModel.saveValidationMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (validationMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.warning),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppTheme.warning),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    validationMessage,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.canSave
                    ? () => _handleSave(context, viewModel)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                  side: BorderSide(
                    color: viewModel.canSave
                        ? AppTheme.primaryPink
                        : AppTheme.border,
                  ),
                ),
                child: Text(
                  'Save Template',
                  style: AppTheme.button.copyWith(
                    color: viewModel.canSave
                        ? AppTheme.primaryPink
                        : AppTheme.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: ElevatedButton(
                onPressed: viewModel.canSave
                    ? () => _handleUpdate(context, viewModel)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                ),
                child: const Text('Update Template'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTemplateHistory(BuildContext context, BudgetingViewModel viewModel) {
    showModalBox(
      context: context,
      width: 800,
      height: 600,
      child: Consumer<AppContext>(
        builder: (context, appContext, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Template History',
                style: AppTheme.h2,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Select a template to adopt or manage your previous templates',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Expanded(
                child: viewModel.templates.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 64,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'No previous templates',
                        style: AppTheme.h3.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        'Your saved templates will appear here',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: viewModel.templates.length,
                  itemBuilder: (context, index) {
                    final template = viewModel.templates[index];
                    final isCurrent = appContext.currentTemplate?.templateId == template.templateId;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacingMd,
                      ),
                      child: FutureBuilder<_TemplateData>(
                        future: _loadTemplateData(viewModel, template.templateId),
                        builder: (context, snapshot) {
                          final templateData = snapshot.data;
                          final totalBudget = templateData?.totalBudget ?? 0.0;
                          final participants = templateData?.participants ?? [];

                          return TemplateHistoryItem(
                            template: template,
                            participants: participants,
                            totalBudget: totalBudget,
                            isCurrent: isCurrent,
                            onAdopt: () => _handleAdoptTemplate(
                              context,
                              viewModel,
                              template,
                            ),
                            onDelete: () => _handleDeleteTemplate(
                              context,
                              viewModel,
                              template,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_TemplateData> _loadTemplateData(
      BudgetingViewModel viewModel,
      int templateId,
      ) async {
    // Load all accounts for the template to calculate total budget
    final accounts = await viewModel.accountService.getAllAccountsForTemplate(templateId);
    final totalBudget = accounts.fold<double>(0.0, (sum, account) => sum + account.budgetAmount);

    // Get unique participants from accounts
    final participantIds = accounts.map((a) => a.responsibleParticipantId).toSet();
    final participants = <models.Participant>[];

    for (var participantId in participantIds) {
      final participant = await viewModel.participantService.getParticipant(participantId);
      if (participant != null) {
        participants.add(participant);
      }
    }

    return _TemplateData(
      totalBudget: totalBudget,
      participants: participants,
    );
  }

  void _handleAdoptTemplate(
      BuildContext context,
      BudgetingViewModel viewModel,
      template,
      ) {
    if (viewModel.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You are currently working on a template.'),
              const SizedBox(height: AppTheme.spacingSm),
              if (viewModel.saveValidationMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXs),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    border: Border.all(color: AppTheme.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Expanded(
                        child: Text(
                          'Note: ${viewModel.saveValidationMessage}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
              ],
              const Text('What would you like to do?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (viewModel.canSave)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleSave(context, viewModel, then: () async {
                    // After saving, adopt the template
                    final appContext = Provider.of<AppContext>(context, listen: false);
                    final currentParticipant = appContext.currentParticipant;
                    if (currentParticipant != null) {
                      await viewModel.adoptTemplate(template, currentParticipant.participantId);
                      appContext.setCurrentTemplate(template);
                      Navigator.of(context).pop(); // Close template history modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Template adopted successfully!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  });
                },
                child: const Text('Save & Adopt'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Get current participant
                final appContext = Provider.of<AppContext>(context, listen: false);
                final currentParticipant = appContext.currentParticipant;

                if (currentParticipant != null) {
                  await viewModel.adoptTemplate(template, currentParticipant.participantId);
                  appContext.setCurrentTemplate(template);
                  Navigator.of(context).pop(); // Close template history modal

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Template adopted successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Discard & Adopt'),
            ),
          ],
        ),
      );
    } else {
      // No unsaved changes, adopt directly
      _adoptTemplateDirectly(context, viewModel, template);
    }
  }

  Future<void> _adoptTemplateDirectly(
      BuildContext context,
      BudgetingViewModel viewModel,
      template,
      ) async {
    final appContext = Provider.of<AppContext>(context, listen: false);
    final currentParticipant = appContext.currentParticipant;

    if (currentParticipant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No participant logged in'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    await viewModel.adoptTemplate(template, currentParticipant.participantId);
    appContext.setCurrentTemplate(template);
    Navigator.of(context).pop(); // Close template history modal

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template adopted successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _handleDeleteTemplate(
      BuildContext context,
      BudgetingViewModel viewModel,
      template,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${template.templateName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTemplate(template.templateId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Template deleted successfully'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleSave(
      BuildContext context,
      BudgetingViewModel viewModel, {
        VoidCallback? then,
      }) {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.saveValidationMessage ?? 'Cannot save template'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Show dialog to get template name
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter a name for this template:'),
              const SizedBox(height: AppTheme.spacingSm),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  hintText: 'e.g., Monthly Budget 2024',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a template name'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Get current participant from context
                final appContext = Provider.of<AppContext>(context, listen: false);
                final currentParticipant = appContext.currentParticipant;

                if (currentParticipant == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No participant logged in'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                  return;
                }

                // Save the template
                final success = await viewModel.saveTemplate(
                  templateName: controller.text.trim(),
                  creatorParticipantId: currentParticipant.participantId,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Template saved successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                  then?.call();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage ?? 'Failed to save template'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleUpdate(BuildContext context, BudgetingViewModel viewModel) {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.saveValidationMessage ?? 'Cannot update template'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Check if we have a current template to update
    final appContext = Provider.of<AppContext>(context, listen: false);
    final currentTemplate = appContext.currentTemplate;

    if (currentTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active template to update. Please save as a new template first.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Template'),
          content: Text(
            'This will replace all categories and accounts in "${currentTemplate.templateName}" with your current changes. This action cannot be undone.\n\nDo you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Update the template
                final success = await viewModel.updateTemplate(
                  templateId: currentTemplate.templateId,
                  templateName: currentTemplate.templateName,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Template updated successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage ?? 'Failed to update template'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPink,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _launchBudgetingGuide() async {
    // TODO: Add actual URL
    final uri = Uri.parse('https://example.com/budgeting-guide');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Helper class for template data
class _TemplateData {
  final double totalBudget;
  final List<models.Participant> participants;

  _TemplateData({
    required this.totalBudget,
    required this.participants,
  });
}