// lib/features/home/widgets/extracted_transactions_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/client_models.dart';
import '../../../core/widgets/content_box.dart';
import '../home_viewmodel.dart';
import 'account_selector.dart';

class ExtractedTransactionsWidget extends StatefulWidget {
  const ExtractedTransactionsWidget({Key? key}) : super(key: key);

  @override
  State<ExtractedTransactionsWidget> createState() =>
      _ExtractedTransactionsWidgetState();
}

class _ExtractedTransactionsWidgetState
    extends State<ExtractedTransactionsWidget> {
  List<CategoryData> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final viewModel = context.read<HomeViewModel>();
    if (viewModel.currentTemplate != null) {
      final categories = await viewModel
          .getTemplateDetails(viewModel.currentTemplate!.templateId);
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentGroup = viewModel.currentDocumentGroup;
    if (currentGroup == null) {
      return const SizedBox.shrink();
    }

    return ContentBox(
      initiallyMinimized: false,
      // previewWidgets: [
      //   Text(
      //     'Document ${viewModel.currentDocumentIndex + 1} of ${viewModel.totalDocuments}',
      //     style: AppTheme.bodySmall,
      //   ),
      //   Text(
      //     '${currentGroup.transactions.length} transactions',
      //     style: AppTheme.bodySmall,
      //   ),
      // ],
      headerWidgets: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify extracted details', style: AppTheme.h3),
            const SizedBox(height: 8),
            Text(
              'Found ${currentGroup.transactions.length} transactions',
              style: AppTheme.bodySmall
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ],
      expandContent: true,
      controls: [
        ContentBoxControl(
          action: ContentBoxAction.refresh,
          onPressed: viewModel.refreshTransactions,
        ),
        ContentBoxControl(
          action: ContentBoxAction.delete,
          onPressed: () => _confirmDelete(context, viewModel),
        ),
        // ContentBoxControl(
        //   action: ContentBoxAction.minimize,
        // ),
      ],
      content: Column(
        children: [
          // Document metadata
          _buildDocumentMetadata(currentGroup),
          const SizedBox(height: 16),
          _buildTransactionGroups(
              context, viewModel, currentGroup.transactions),
          const SizedBox(height: 24),
          // Navigation controls
          _buildNavigationControls(viewModel),

          const SizedBox(height: 16),
          _buildActionButtons(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildDocumentMetadata(DocumentTransactionGroup group) {
    final viewModel = context.watch<HomeViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description,
                  size: 20, color: context.colors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.document.fileName,
                  style:
                      AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (group.isComplete || group.hasAllAccountsAssigned)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: context.colors.success),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: context.colors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Complete',
                        style: AppTheme.caption
                            .copyWith(color: context.colors.success),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _buildMetadataItem(
                      icon: Icons.person,
                      label: 'Owner',
                      value: 'Participant ${group.document.ownerParticipantId}',
                    ),
                    _buildMetadataItem(
                      icon: Icons.account_balance,
                      label: 'Institution',
                      value: group.document.institution.displayName,
                    ),
                    _buildMetadataItem(
                      icon: Icons.receipt_long,
                      label: 'Transactions',
                      value: '${group.transactions.length}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Auto-update toggle
              InkWell(
                onTap: viewModel.toggleAutoUpdateVendorAssociations,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: viewModel.autoUpdateVendorAssociations
                        ? context.colors.primary.withOpacity(0.1)
                        : context.colors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: viewModel.autoUpdateVendorAssociations
                          ? context.colors.primary
                          : context.colors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        viewModel.autoUpdateVendorAssociations
                            ? Icons.auto_fix_high
                            : Icons.auto_fix_off,
                        size: 16,
                        color: viewModel.autoUpdateVendorAssociations
                            ? context.colors.primary
                            : context.colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Auto-update\nVendors',
                        textAlign: TextAlign.center,
                        style: AppTheme.caption.copyWith(
                          fontSize: 10,
                          color: viewModel.autoUpdateVendorAssociations
                              ? context.colors.primary
                              : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.colors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTheme.caption
                    .copyWith(color: context.colors.textSecondary)),
            Text(value,
                style:
                    AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationControls(HomeViewModel viewModel) {
    return Row(
      children: [
        // Previous button
        IconButton(
          onPressed:
              viewModel.canGoToPrevious ? viewModel.goToPreviousDocument : null,
          icon: const Icon(Icons.arrow_back),
          color: context.colors.secondary,
          disabledColor: context.colors.textSecondary.withOpacity(0.3),
          tooltip: 'Previous document',
        ),
        const SizedBox(width: 8),

        // Document indicator
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Document ${viewModel.currentDocumentIndex + 1} of ${viewModel.totalDocuments}',
                  style:
                      AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                // Progress dots
                ...List.generate(
                  viewModel.totalDocuments,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == viewModel.currentDocumentIndex
                            ? context.colors.secondary
                            : index < viewModel.currentDocumentIndex
                                ? context.colors.success
                                : context.colors.border,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),
        // Next button
        IconButton(
          onPressed:
              viewModel.canProceedToNext ? viewModel.goToNextDocument : null,
          icon: const Icon(Icons.arrow_forward),
          color: context.colors.secondary,
          disabledColor: context.colors.textSecondary.withOpacity(0.3),
          tooltip: viewModel.isCurrentDocumentComplete
              ? 'Next document'
              : 'Complete all transactions first',
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, HomeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Progress indicator
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${viewModel.documentGroups.where((g) => g.isComplete).length} of ${viewModel.totalDocuments} documents completed',
                style: AppTheme.bodySmall
                    .copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: viewModel.totalDocuments > 0
                    ? viewModel.documentGroups
                            .where((g) => g.isComplete)
                            .length /
                        viewModel.totalDocuments
                    : 0,
                backgroundColor: context.colors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(context.colors.success),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Complete Audit button
        ElevatedButton.icon(
          onPressed: viewModel.areAllDocumentsComplete
              ? () => _completeAudit(context, viewModel)
              : null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Audit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            disabledBackgroundColor: context.colors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionGroups(BuildContext context, HomeViewModel viewModel,
      List<ParsedTransaction> transactions) {
    // Group transactions by their ORIGINAL status
    final criticalTxns = <ParsedTransaction>[];
    final potentialTxns = <ParsedTransaction>[];
    final ambiguousTxns = <ParsedTransaction>[];
    final confidentTxns = <ParsedTransaction>[];

    for (final txn in transactions) {
      switch (txn.originalStatus ?? txn.matchStatus) {
        case MatchStatus.critical:
          criticalTxns.add(txn);
          break;
        case MatchStatus.potential:
          potentialTxns.add(txn);
          break;
        case MatchStatus.ambiguous:
          ambiguousTxns.add(txn);
          break;
        case MatchStatus.confident:
          confidentTxns.add(txn);
          break;
      }
    }

    return Column(
      children: [
        if (criticalTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: criticalTxns,
            status: MatchStatus.critical,
            title: 'Your Input is Required',
            description:
                'The vendors are not recognized by the system. Your review is required to continue.',
            color: context.colors.error,
          ),
        if (criticalTxns.isNotEmpty) const SizedBox(height: 16),
        if (potentialTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: potentialTxns,
            status: MatchStatus.potential,
            title: 'Please review vendor names',
            description:
                'Vendor names resemble vendors you have interacted with. Consider reviewing to ensure accuracy',
            color: Colors.orange,
          ),
        if (potentialTxns.isNotEmpty) const SizedBox(height: 16),
        if (ambiguousTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: ambiguousTxns,
            status: MatchStatus.ambiguous,
            title: 'Review historical associations',
            description:
                'Transaction Vendors have been matched, but there exist differing historical associations. Consider reviewing for accuracy.',
            color: const Color(0xFF86EFAC),
          ),
        if (ambiguousTxns.isNotEmpty) const SizedBox(height: 16),
        if (confidentTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: confidentTxns,
            status: MatchStatus.confident,
            title: 'Verified transactions',
            description:
                'Transaction Vendors have been accurately matched. Consider reviewing for accuracy.',
            color: context.colors.success,
          ),
      ],
    );
  }

  Widget _buildStatusGroup({
    required BuildContext context,
    required HomeViewModel viewModel,
    required List<ParsedTransaction> transactions,
    required MatchStatus status,
    required String title,
    required String description,
    required Color color,
  }) {
    final unmodifiedCount = transactions
        .where((txn) =>
            txn.suggestedAccount == null ||
            (!txn.userModified && !txn.autoUpdated))
        .length;

    return ContentBox(
      initiallyMinimized: false,
      headerWidgets: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$title',
              style: AppTheme.bodySmall
                  .copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: description,
              triggerMode: TooltipTriggerMode.tap,
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          'Total: ${transactions.length} transactions',
          style:
              AppTheme.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
        Text(
          '$unmodifiedCount ${unmodifiedCount == 1 ? 'transaction remaining' : 'transactions remaining'}',
          style:
              AppTheme.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
      ],
      previewWidgets: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AppTheme.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: description,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      size: 14,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          '$unmodifiedCount ${unmodifiedCount == 1 ? 'transaction' : 'transactions'}',
          style:
              AppTheme.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
      ],
      controls: const [
        ContentBoxControl(action: ContentBoxAction.minimize),
      ],
      expandContent: true,
      content: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            _TransactionContentBox(
              key: ValueKey(transactions[i].id),
              transaction: transactions[i],
              categories: _categories,
              originalStatus: status,
              onUpdate: (updated) => viewModel.updateTransaction(updated),
              onSplit: (amount, accountName) {
                viewModel.splitTransaction(
                    transactions[i].id, amount, accountName);
              },
              onDeleteRecommendation: (vendorId, accountId) {
                viewModel.deleteVendorRecommendation(vendorId, accountId);
              },
            ),
            if (i < transactions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _completeAudit(
      BuildContext context, HomeViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Audit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'You are about to save all transactions to the database.'),
            const SizedBox(height: 16),
            Text(
              'Total: ${viewModel.documentGroups.fold(0, (sum, group) => sum + group.transactions.length)} transactions',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Documents: ${viewModel.totalDocuments}',
              style: AppTheme.bodySmall
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.success),
            child: const Text('Save All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.completeAudit();
      if (context.mounted && success) {
        // State is now handled by HomeViewModel.auditCompletedSuccessfully
        // and shown in HomeView.buildSuccessView
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, HomeViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transactions'),
        content: const Text(
            'This will remove all extracted transactions for this document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      viewModel.clearTransactions();
    }
  }
}

// Keep the same _TransactionContentBox implementation from before
class _TransactionContentBox extends StatelessWidget {
  final ParsedTransaction transaction;
  final List<CategoryData> categories;
  final MatchStatus originalStatus;
  final ValueChanged<ParsedTransaction> onUpdate;
  final Function(double, String) onSplit;
  final Function(int, int) onDeleteRecommendation;

  const _TransactionContentBox({
    Key? key,
    required this.transaction,
    required this.categories,
    required this.originalStatus,
    required this.onUpdate,
    required this.onSplit,
    required this.onDeleteRecommendation,
  }) : super(key: key);

  Color _getStatusColor(BuildContext context, MatchStatus status) {
    switch (status) {
      case MatchStatus.critical:
        return context.colors.error;
      case MatchStatus.potential:
        return Colors.orange;
      case MatchStatus.ambiguous:
        return const Color(0xFF86EFAC);
      case MatchStatus.confident:
        return context.colors.success;
    }
  }

  Color _getCurrentColor(BuildContext context) {
    if (transaction.userModified) {
      return context.colors.success;
    } else if (transaction.autoUpdated) {
      return const Color(0xFFBBF7D0);
    }
    return _getStatusColor(context, originalStatus);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getCurrentColor(context);

    return ContentBox(
      initiallyMinimized: true,
      expandContent: true,
      previewWidgets: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                transaction.vendorName,
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (transaction.autoUpdated && !transaction.userModified)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.auto_fix_high,
                  size: 14,
                  color: Colors.green.shade600,
                ),
              ),
          ],
        ),
        Text(
          '${transaction.amount < 0 ? '-' : '+'}${transaction.amount.abs().toStringAsFixed(2)}',
          style: AppTheme.bodyMedium.copyWith(
            color: transaction.amount < 0
                ? context.colors.error
                : context.colors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        EnhancedAccountSelector(
          categories: categories,
          selectedAccountId: transaction.suggestedAccount?.id,
          vendorId: transaction.vendorId,
          onAccountSelected: (account) async {
            final viewModel = context.read<HomeViewModel>();

            // Check if we should prompt for vendor-wide update
            // Allow prompt if vendorId IS present OR vendorName is present (relaxed)
            final shouldPrompt = viewModel.autoUpdateVendorAssociations &&
                !transaction.userModified;

            if (shouldPrompt) {
              // Count other transactions with same vendor
              final sameVendorCount = viewModel.documentGroups
                  .expand((g) => g.transactions)
                  .where((t) {
                // Must not be self
                if (t.id == transaction.id) return false;
                // Must not be already modified
                if (t.userModified) return false;

                // Match by ID if both have it
                if (t.vendorId != null && transaction.vendorId != null) {
                  return t.vendorId == transaction.vendorId;
                }
                // Fallback to name match
                return t.vendorName.toLowerCase().trim() ==
                    transaction.vendorName.toLowerCase().trim();
              }).length;

              if (sameVendorCount > 0) {
                final result = await _showVendorUpdateDialog(
                  context,
                  transaction.vendorName,
                  account.name,
                  sameVendorCount,
                  viewModel.toggleAutoUpdateVendorAssociations,
                );

                if (result == true) {
                  // Update with propagation
                  viewModel.updateTransaction(
                    transaction.copyWith(
                      account: account.name,
                      suggestedAccount: account,
                      matchStatus: MatchStatus.confident,
                      userModified: true,
                      autoUpdated: false,
                    ),
                    propagateToOthers: true,
                  );
                  return;
                }
              }
            }

            // Standard update without propagation
            onUpdate(transaction.copyWith(
              account: account.name,
              suggestedAccount: account,
              matchStatus: MatchStatus.confident,
              userModified: true,
              autoUpdated: false,
            ));
          },
          onDeleteRecommendation: onDeleteRecommendation,
        ),
      ],
      headerWidgets: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy').format(transaction.date),
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            if (transaction.autoUpdated && !transaction.userModified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  'Auto-updated',
                  style: AppTheme.caption.copyWith(
                    color: Colors.green.shade700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
      controls: const [
        ContentBoxControl(action: ContentBoxAction.minimize),
      ],
      content: _buildExpandedContent(context),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vendor', style: AppTheme.caption),
                  const SizedBox(height: 4),
                  Text(
                    transaction.vendorName,
                    style: AppTheme.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (transaction.potentialMatches.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Similar: ${transaction.potentialMatches.join(", ")}',
                      style: AppTheme.caption.copyWith(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Amount', style: AppTheme.caption),
                const SizedBox(height: 4),
                Text(
                  '${transaction.amount < 0 ? '-' : '+'}${transaction.amount.abs().toStringAsFixed(2)}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: transaction.amount < 0
                        ? context.colors.error
                        : context.colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Account', style: AppTheme.caption),
        const SizedBox(height: 8),
        EnhancedAccountSelector(
          categories: categories,
          selectedAccountId: transaction.suggestedAccount?.id,
          vendorId: transaction.vendorId,
          onAccountSelected: (account) async {
            final viewModel = context.read<HomeViewModel>();

            // Check if we should prompt for vendor-wide update
            final shouldPrompt = viewModel.autoUpdateVendorAssociations &&
                transaction.vendorId != null &&
                !transaction.userModified;

            if (shouldPrompt) {
              // Count other transactions with same vendor
              final sameVendorCount = viewModel.documentGroups
                  .expand((g) => g.transactions)
                  .where((t) =>
                      t.id != transaction.id &&
                      t.vendorId == transaction.vendorId &&
                      !t.userModified)
                  .length;

              if (sameVendorCount > 0) {
                final result = await _showVendorUpdateDialog(
                  context,
                  transaction.vendorName,
                  account.name,
                  sameVendorCount,
                  viewModel.toggleAutoUpdateVendorAssociations,
                );

                if (result == true) {
                  // Update with propagation
                  viewModel.updateTransaction(
                    transaction.copyWith(
                      account: account.name,
                      suggestedAccount: account,
                      matchStatus: MatchStatus.confident,
                      userModified: true,
                      autoUpdated: false,
                    ),
                    propagateToOthers: true,
                  );
                  return;
                }
              }
            }

            // Standard update without propagation
            onUpdate(transaction.copyWith(
              account: account.name,
              suggestedAccount: account,
              matchStatus: MatchStatus.confident,
              userModified: true,
              autoUpdated: false,
            ));
          },
          onDeleteRecommendation: onDeleteRecommendation,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showSplitDialog(context),
              icon: const Icon(Icons.call_split, size: 18),
              label: const Text('Split Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: transaction.useMemory,
                  onChanged: (val) {
                    onUpdate(transaction.copyWith(
                      useMemory: val,
                      userModified: true,
                    ));
                  },
                  activeColor: context.colors.primary,
                ),
                const Text('Remember', style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showSplitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SplitTransactionDialog(
        transaction: transaction,
        categories: categories,
        onSplit: onSplit,
      ),
    );
  }
}

// Keep the same _SplitTransactionDialog from before
class _SplitTransactionDialog extends StatefulWidget {
  final ParsedTransaction transaction;
  final List<CategoryData> categories;
  final Function(double, String) onSplit;

  const _SplitTransactionDialog({
    required this.transaction,
    required this.categories,
    required this.onSplit,
  });

  @override
  State<_SplitTransactionDialog> createState() =>
      _SplitTransactionDialogState();
}

class _SplitTransactionDialogState extends State<_SplitTransactionDialog> {
  late TextEditingController _amountController;
  AccountData? _selectedAccount;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndSplit() {
    final amount = double.tryParse(_amountController.text);
    final maxAmount = widget.transaction.amount.abs();

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    if (amount >= maxAmount) {
      setState(() {
        _errorMessage =
            'Split amount must be less than ${maxAmount.toStringAsFixed(2)}';
      });
      return;
    }

    if (_selectedAccount == null) {
      setState(() {
        _errorMessage = 'Please select an account';
      });
      return;
    }

    widget.onSplit(amount, _selectedAccount!.name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Split Transaction'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original Amount: ${widget.transaction.amount.abs().toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Split Amount',
                hintText: 'Enter amount to split',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Assign to Account', style: AppTheme.caption),
            const SizedBox(height: 8),
            EnhancedAccountSelector(
              categories: widget.categories,
              selectedAccountId: _selectedAccount?.id,
              vendorId: null,
              onAccountSelected: (account) {
                setState(() {
                  _selectedAccount = account;
                  if (_errorMessage == 'Please select an account') {
                    _errorMessage = null;
                  }
                });
              },
              onDeleteRecommendation: (_, __) {},
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSplit,
          child: const Text('Split'),
        ),
      ],
    );
  }
}

/// Shows a dialog asking if user wants to update all transactions with same vendor
Future<bool?> _showVendorUpdateDialog(
  BuildContext context,
  String vendorName,
  String accountName,
  int affectedCount,
  Function() onDisableAutoUpdate,
) {
  bool dontAskAgain = false;

  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: context.colors.primary),
            const SizedBox(width: 8),
            const Text('Update All Vendors?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTheme.bodyMedium
                    .copyWith(color: context.colors.textPrimary),
                children: [
                  const TextSpan(text: 'You\'ve assigned '),
                  TextSpan(
                    text: '"$vendorName"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: '"$accountName"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: context.colors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Found $affectedCount other ${affectedCount == 1 ? 'transaction' : 'transactions'} '
                      'with "$vendorName" that haven\'t been labeled yet.',
                      style: AppTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Would you like to update all of them to this account?',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: dontAskAgain,
                    onChanged: (value) {
                      setState(() {
                        dontAskAgain = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        dontAskAgain = !dontAskAgain;
                      });
                    },
                    child: const Text('Don\'t ask me again for other vendors',
                        style: AppTheme.bodySmall),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (dontAskAgain) {
                onDisableAutoUpdate();
              }
              Navigator.pop(context, false);
            },
            child: const Text('Just This One'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (dontAskAgain) {
                onDisableAutoUpdate();
              }
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.done_all, size: 18),
            label: Text('Update All ($affectedCount)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }),
  );
}
