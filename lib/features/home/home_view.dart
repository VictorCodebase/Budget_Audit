// lib/features/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_header.dart';
import 'home_viewmodel.dart';
import 'widgets/document_ingestion_widget.dart';
import 'widgets/extracted_transactions_widget.dart';
import 'widgets/side_panel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Refresh history data when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().refreshHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 1024;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Transparent to show global gradient
      body: SafeArea(
          child: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(
                subtitle: 'Document Analysis & Transaction Extraction',
              ),
              isWideScreen
                  ? _buildWideScreenLayout(context, viewModel)
                  : _buildNarrowScreenLayout(context, viewModel),
            ],
          ),
        ),
      ])),
    );
  }

  Widget _buildWideScreenLayout(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area
        Expanded(
          flex: 3,
          child: _buildMainContent(context, viewModel),
        ),
        // Side panel
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          child: const SidePanel(),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    return _buildMainContent(context, viewModel);
  }

  Widget _buildMainContent(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data handling notice
          _buildDataHandlingNotice(context),
          const SizedBox(height: AppTheme.spacingLg),

          // Document ingestion
          const DocumentIngestionWidget(),
          const SizedBox(height: AppTheme.spacingLg),

          // Loading indicator
          if (viewModel.isLoading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (viewModel.auditCompletedSuccessfully) ...[
            _buildSuccessView(context, viewModel),
          ] else if (viewModel.hasRunAudit) ...[
            // Extracted transactions (only shown after audit)
            const ExtractedTransactionsWidget(),
          ],

          // Error message
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            _buildErrorMessage(context, viewModel.errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildDataHandlingNotice(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.shield_outlined,
          color: context.colors.success,
          size: 20,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              children: [
                const TextSpan(
                  text: 'Your financial documents never leave your device. ',
                ),
                TextSpan(
                  text: 'Learn more about Budget Audit data handling here',
                  style: TextStyle(
                    color: context.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.error.withOpacity(0.1),
        border: Border.all(color: context.colors.error, width: 1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.colors.error, size: 20),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodySmall.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: context.colors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.colors.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: context.colors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: context.colors.success,
              size: 48,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Audit Completed Successfully!',
            style: AppTheme.h2.copyWith(color: context.colors.success),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'All transactions have been verified and saved to the database. You can now view the detailed analysis.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium
                .copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => viewModel.reset(),
                icon: const Icon(Icons.refresh),
                label: const Text('Start New Audit'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/analytics');
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('View Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
