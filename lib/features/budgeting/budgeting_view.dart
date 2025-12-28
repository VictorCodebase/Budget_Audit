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
  // Cache for template data futures to prevent recreation on rebuild
  final Map<int, Future<_TemplateData>> _templateDataCache = {};
  late TextEditingController _customPeriodController;

  @override
  void initState() {
    super.initState();
    _customPeriodController = TextEditingController(text: '1');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BudgetingViewModel>();
      viewModel.initialize();
      viewModel.addListener(_onViewModelChange);
    });
  }

  void _onViewModelChange() {
    final viewModel = context.read<BudgetingViewModel>();
    if (viewModel.selectedPeriod == 'Custom') {
      final text = viewModel.customPeriodMonths.toString();
      if (_customPeriodController.text != text) {
        _customPeriodController.text = text;
      }
    }
  }

  @override
  void dispose() {
    context.read<BudgetingViewModel>().removeListener(_onViewModelChange);
    _templateDataCache.clear();
    _customPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appContext = Provider.of<AppContext>(context);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Transparent to show global gradient
      body: SafeArea(
        child: Stack(
          children: [
            Consumer<BudgetingViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Mobile breakpoint
                    final isMobile = constraints.maxWidth < 800;

                    if (isMobile) {
                      // Mobile: Header scrolls away with content
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const AppHeader(
                              subtitle:
                                  'Create and manage your budget templates',
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMainContainer(
                                      context, viewModel, appContext),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Desktop: Header fixed at top
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
                                  _buildMainContainer(
                                      context, viewModel, appContext),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              },
            ),
            // Menu always accessible on top left
          ],
        ),
      ),
    );
  }

  Widget _buildMainContainer(BuildContext context, BudgetingViewModel viewModel,
      AppContext appContext) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: context.colors.background,
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
                'Create a Budget Template',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Container(
                height: 3,
                width: 200,
                decoration: BoxDecoration(
                  color: context.colors.primary,
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
                      onTap: () => _showTemplateHistory(context),
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
                      onTap: () => _showTemplateHistory(context),
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
              Flexible(
                child: TextButton.icon(
                  onPressed: () => _launchBudgetingGuide(),
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: Text(
                    'Learn how budgeting works in the Budget Audit',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.colors.secondary,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          _buildInformationBox(appContext),
          const SizedBox(height: AppTheme.spacingXl),

          // Period Selector
          _buildPeriodSelector(context, viewModel),
          const SizedBox(height: AppTheme.spacingXl),

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
                child: CategoryWidget(
                  key: ValueKey(category.id),
                  category: category,
                ),
              );
            }),

          const SizedBox(height: AppTheme.spacingMd),

          // Add category button
          InkWell(
            onTap: () => viewModel.addCategory(),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.add_box_outlined,
                    size: 22, color: context.colors.primary),
                const SizedBox(width: 6),
                Text(
                  "Add Category",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacing2xl),

          // Save/Update buttons
          _buildActionButtons(context, viewModel, appContext),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing2xl),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: context.colors.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No categories yet',
            style: AppTheme.h3.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Add your first category to start building your budget',
            style: AppTheme.bodyMedium
                .copyWith(color: context.colors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInformationBox(AppContext appContext) {
    final currentTemplate = appContext.currentTemplate;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            currentTemplate != null
                ? Icons.info_outline
                : Icons.lightbulb_outline,
            color: context.colors.secondary,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: currentTemplate != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTheme.bodyMedium
                              .copyWith(color: context.colors.textSecondary),
                          children: [
                            const TextSpan(
                                text: 'You are currently working on the "'),
                            TextSpan(
                              text: currentTemplate.templateName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '" template.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          context.read<BudgetingViewModel>().startNewTemplate();
                        },
                        child: Text(
                          'Create new budget',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.colors.secondary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'You don\'t have an active budget. Create a new template or import a previous one to get started.',
                    style: AppTheme.bodyMedium
                        .copyWith(color: context.colors.textSecondary),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BudgetingViewModel viewModel,
      AppContext appContext) {
    final validationMessage = viewModel.saveValidationMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (validationMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: context.colors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: context.colors.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: context.colors.warning),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    validationMessage,
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.colors.warning,
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
                        ? context.colors.textSecondary
                        : context.colors.border,
                  ),
                ),
                child: Text(
                  'Save As New Template',
                  style: AppTheme.button.copyWith(
                    color: viewModel.canSave
                        ? context.colors.textSecondary
                        : context.colors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            if (appContext.currentTemplate != null)
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
                  child: const Text('Update The Current Template'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showTemplateHistory(BuildContext context) {
    // Capture the viewModel from the current context before opening modal
    final viewModel = context.read<BudgetingViewModel>();

    showModalBox(
      context: context,
      width: 800,
      height: 600,
      child: Builder(
        builder: (modalContext) {
          // Use the outer context's viewModel, but modal's context for AppContext
          return Consumer<AppContext>(
            builder: (_, appContext, __) {
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
                    style: AppTheme.bodyMedium
                        .copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Expanded(
                    child: viewModel.templates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: context.colors.textTertiary,
                                ),
                                const SizedBox(height: AppTheme.spacingMd),
                                Text(
                                  'No previous templates',
                                  style: AppTheme.h3.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingXs),
                                Text(
                                  'Your saved templates will appear here',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: context.colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: viewModel.templates.length,
                            itemBuilder: (context, index) {
                              final template = viewModel.templates[index];
                              final isCurrent =
                                  appContext.currentTemplate?.templateId ==
                                      template.templateId;

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppTheme.spacingMd,
                                ),
                                child: FutureBuilder<_TemplateData>(
                                  future: _getCachedTemplateData(
                                      viewModel, template.templateId),
                                  builder: (context, snapshot) {
                                    final templateData = snapshot.data;
                                    final totalBudget =
                                        templateData?.totalBudget ?? 0.0;
                                    final participants =
                                        templateData?.participants ?? [];

                                    return TemplateHistoryItem(
                                      template: template,
                                      participants: participants,
                                      totalBudget: totalBudget,
                                      isCurrent: isCurrent,
                                      onAdopt: () => _handleAdoptTemplate(
                                        modalContext,
                                        viewModel,
                                        template,
                                      ),
                                      onDelete: () => _handleDeleteTemplate(
                                        modalContext,
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
          );
        },
      ),
    );
  }

  /// Gets cached template data future to prevent recreation on rebuild
  Future<_TemplateData> _getCachedTemplateData(
    BudgetingViewModel viewModel,
    int templateId,
  ) {
    return _templateDataCache.putIfAbsent(
      templateId,
      () => _loadTemplateData(viewModel, templateId),
    );
  }

  Future<_TemplateData> _loadTemplateData(
    BudgetingViewModel viewModel,
    int templateId,
  ) async {
    // Load all accounts for the template to calculate total budget
    final accounts =
        await viewModel.accountService.getAllAccountsForTemplate(templateId);
    final totalBudget = accounts.fold<double>(
        0.0, (sum, account) => sum + account.budgetAmount);

    // Get unique participants from accounts
    final participantIds =
        accounts.map((a) => a.responsibleParticipantId).toSet();
    final participants = <models.Participant>[];

    for (var participantId in participantIds) {
      final participant =
          await viewModel.participantService.getParticipant(participantId!);
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
                    color: context.colors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    border: Border.all(color: context.colors.warning),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: context.colors.warning,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Expanded(
                        child: Text(
                          'Note: ${viewModel.saveValidationMessage}',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.colors.warning,
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
                    final appContext =
                        Provider.of<AppContext>(context, listen: false);
                    final currentParticipant = appContext.currentParticipant;
                    if (currentParticipant != null) {
                      await viewModel.adoptTemplate(
                          template, currentParticipant.participantId);
                      appContext.setCurrentTemplate(template);
                      if (context.mounted) {
                        Navigator.of(context)
                            .pop(); // Close template history modal
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Template adopted successfully!'),
                            backgroundColor: context.colors.success,
                          ),
                        );
                      }
                    }
                  });
                },
                child: const Text('Save & Adopt'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Get current participant
                final appContext =
                    Provider.of<AppContext>(context, listen: false);
                final currentParticipant = appContext.currentParticipant;

                if (currentParticipant != null) {
                  await viewModel.adoptTemplate(
                      template, currentParticipant.participantId);
                  appContext.setCurrentTemplate(template);
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close template history modal

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Template adopted successfully!'),
                        backgroundColor: context.colors.success,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: context.colors.error,
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No participant logged in'),
            backgroundColor: context.colors.error,
          ),
        );
      }
      return;
    }

    await viewModel.adoptTemplate(template, currentParticipant.participantId);
    appContext.setCurrentTemplate(template);

    if (context.mounted) {
      Navigator.of(context).pop(); // Close template history modal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Template adopted successfully!'),
          backgroundColor: context.colors.success,
        ),
      );
    }
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
            onPressed: () async {
              await viewModel.deleteTemplate(template.templateId);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Template deleted successfully'),
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

  void _handleSave(
    BuildContext context,
    BudgetingViewModel viewModel, {
    VoidCallback? then,
  }) {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(viewModel.saveValidationMessage ?? 'Cannot save template'),
          backgroundColor: context.colors.error,
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
                    SnackBar(
                      content: const Text('Please enter a template name'),
                      backgroundColor: context.colors.error,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Get current participant from context
                final appContext =
                    Provider.of<AppContext>(context, listen: false);
                final currentParticipant = appContext.currentParticipant;

                if (currentParticipant == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('No participant logged in'),
                        backgroundColor: context.colors.error,
                      ),
                    );
                  }
                  return;
                }

                // Save the template
                final success = await viewModel.saveTemplate(
                  templateName: controller.text.trim(),
                  creatorParticipantId: currentParticipant.participantId,
                );

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Template saved successfully!'),
                        backgroundColor: context.colors.success,
                      ),
                    );
                    then?.call();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(viewModel.errorMessage ??
                            'Failed to save template'),
                        backgroundColor: context.colors.error,
                      ),
                    );
                  }
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
          content:
              Text(viewModel.saveValidationMessage ?? 'Cannot update template'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    // Check if we have a current template to update
    final appContext = Provider.of<AppContext>(context, listen: false);
    final currentTemplate = appContext.currentTemplate;

    if (currentTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'No active template to update. Please save as a new template first.'),
          backgroundColor: context.colors.warning,
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

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Template updated successfully!'),
                        backgroundColor: context.colors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(viewModel.errorMessage ??
                            'Failed to update template'),
                        backgroundColor: context.colors.error,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: context.colors.primary,
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

  Widget _buildPeriodSelector(
      BuildContext context, BudgetingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Period',
          style: AppTheme.h3,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select the duration for this budget',
          style:
              AppTheme.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: context.colors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: viewModel.selectedPeriod,
                  items: viewModel.availablePeriods.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      viewModel.setPeriod(newValue);
                    }
                  },
                  dropdownColor: context.colors.surface,
                ),
              ),
            ),
            if (viewModel.selectedPeriod == 'Custom') ...[
              const SizedBox(width: AppTheme.spacingMd),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _customPeriodController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Months',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  onChanged: (value) {
                    final months = int.tryParse(value);
                    if (months != null) {
                      viewModel.setCustomPeriodMonths(months);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
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
