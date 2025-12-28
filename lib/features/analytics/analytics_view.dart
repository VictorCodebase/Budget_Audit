// lib/features/analytics/analytics_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_header.dart';
import '../../core/theme/app_theme.dart';
import 'analytics_viewmodel.dart';
import 'widgets/budget_analytics_tab.dart';
import 'widgets/expenditure_analytics_tab.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({Key? key}) : super(key: key);

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              subtitle: 'Budget Insights & Spending Analysis',
            ),
            Expanded(
              child: viewModel.isLoading
                  ? _buildLoadingState()
                  : viewModel.errorMessage != null
                      ? _buildErrorState(viewModel.errorMessage!)
                      : _buildContent(context, viewModel, isWideScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colors.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Loading analytics...',
            style: AppTheme.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Unable to Load Analytics',
              style: AppTheme.h3.copyWith(
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              error,
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AnalyticsViewModel>().refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AnalyticsViewModel viewModel,
    bool isWideScreen,
  ) {
    return Column(
      children: [
        _buildTabSelector(context, viewModel),
        _buildTemplateSelector(context, viewModel),
        Expanded(
          child: viewModel.currentTab == AnalyticsTab.budgetAnalytics
              ? const BudgetAnalyticsTab()
              : const ExpenditureAnalyticsTab(),
        ),
      ],
    );
  }

  Widget _buildTabSelector(BuildContext context, AnalyticsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              'Budget Analytics',
              AnalyticsTab.budgetAnalytics,
              viewModel.currentTab == AnalyticsTab.budgetAnalytics,
              () => viewModel.setTab(AnalyticsTab.budgetAnalytics),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              'Expenditure Analysis',
              AnalyticsTab.expenditureAnalysis,
              viewModel.currentTab == AnalyticsTab.expenditureAnalysis,
              () => viewModel.setTab(AnalyticsTab.expenditureAnalysis),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String label,
    AnalyticsTab tab,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.button.copyWith(
            color: isSelected ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    if (viewModel.availableTemplates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            'Budget Period:',
            style: AppTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: DropdownButton<int>(
              value: viewModel.selectedTemplate?.templateId,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: context.colors.textPrimary,
              ),
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textPrimary,
              ),
              items: viewModel.availableTemplates.map((template) {
                return DropdownMenuItem<int>(
                  value: template.templateId,
                  child: Text(
                    '${template.templateName} (${template.period})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final template = viewModel.availableTemplates.firstWhere(
                    (t) => t.templateId == value,
                  );
                  viewModel.selectTemplate(template);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
