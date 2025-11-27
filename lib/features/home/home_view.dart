// lib/features/home/home_view.dart

import 'package:budget_audit/features/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_header.dart';
import 'home_viewmodel.dart';
import 'widgets/document_ingestion_widget.dart';
import 'widgets/extracted_transactions_widget.dart';
import 'widgets/side_panel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
          child: Stack(children: [
        Column(
          children: [
            const AppHeader(
              subtitle: 'Document Analysis & Transaction Extraction',
            ),
            Expanded(
              child: isWideScreen
                  ? _buildWideScreenLayout(context, viewModel)
                  : _buildNarrowScreenLayout(context, viewModel),
            ),
          ],
        ),
        const Positioned(
          top: 12, // Align with AppHeader padding
          left: 24,
          child: Menu(),
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
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppTheme.border, width: 1),
            ),
          ),
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
    return SingleChildScrollView(
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

          // Extracted transactions (only shown after audit)
          if (viewModel.hasRunAudit) ...[
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
          color: AppTheme.success,
          size: 20,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              children: [
                const TextSpan(
                  text: 'Your financial documents never leave your device. ',
                ),
                TextSpan(
                  text: 'Learn more about Budget Audit data handling here',
                  style: TextStyle(
                    color: AppTheme.primaryPink,
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
        color: AppTheme.error.withOpacity(0.1),
        border: Border.all(color: AppTheme.error, width: 1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
