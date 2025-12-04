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

    return ContentBox(
      initiallyMinimized: false,
      previewWidgets: [
        Text(
          'File Owner: ${viewModel.uploadedDocuments.firstOrNull?.ownerParticipantId ?? "Unknown"}',
          style: AppTheme.bodySmall,
        ),
        Text(
          'Files: ${viewModel.uploadedDocuments.length}',
          style: AppTheme.bodySmall,
        ),
      ],
      headerWidgets: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify extracted details', style: AppTheme.h3),
            const SizedBox(height: 8),
            Text(
              'Found ${viewModel.extractedTransactions.length} transactions',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
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
        ContentBoxControl(
          action: ContentBoxAction.minimize,
        ),
      ],
      content: _buildTransactionGroups(context, viewModel),
    );
  }

  Widget _buildTransactionGroups(
      BuildContext context, HomeViewModel viewModel) {
    // Group transactions by their ORIGINAL status (preserve position)
    final criticalTxns = <ParsedTransaction>[];
    final potentialTxns = <ParsedTransaction>[];
    final ambiguousTxns = <ParsedTransaction>[];
    final confidentTxns = <ParsedTransaction>[];

    for (final txn in viewModel.extractedTransactions) {
      // Use originalStatus to determine group placement
      // This keeps transactions in their original group even after modification
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
        // Critical transactions
        if (criticalTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: criticalTxns,
            status: MatchStatus.critical,
            title: 'Your Input is Required',
            color: AppTheme.error,
          ),
        if (criticalTxns.isNotEmpty) const SizedBox(height: 16),

        // Potential transactions
        if (potentialTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: potentialTxns,
            status: MatchStatus.potential,
            title: 'Please review vendor names',
            color: Colors.orange,
          ),
        if (potentialTxns.isNotEmpty) const SizedBox(height: 16),

        // Ambiguous transactions
        if (ambiguousTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: ambiguousTxns,
            status: MatchStatus.ambiguous,
            title: 'Review historical associations',
            color: const Color(0xFF86EFAC),
          ),
        if (ambiguousTxns.isNotEmpty) const SizedBox(height: 16),

        // Confident transactions
        if (confidentTxns.isNotEmpty)
          _buildStatusGroup(
            context: context,
            viewModel: viewModel,
            transactions: confidentTxns,
            status: MatchStatus.confident,
            title: 'Verified transactions',
            color: AppTheme.success,
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
    required Color color,
  }) {
    // Count transactions that haven't been modified (still need action)
    final unmodifiedCount = transactions
        .where((txn) =>
            txn.suggestedAccount == null ||
            (!txn.userModified && !txn.autoUpdated))
        .length;

    return ContentBox(
      initiallyMinimized: false,
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
              child: Text(
                title,
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Text(
          '$unmodifiedCount ${unmodifiedCount == 1 ? 'transaction' : 'transactions'}',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
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
              key:
                  ValueKey(transactions[i].id), // Important for widget identity
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

  Future<void> _confirmDelete(
      BuildContext context, HomeViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transactions'),
        content: const Text('This will remove all extracted transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
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

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.critical:
        return AppTheme.error;
      case MatchStatus.potential:
        return Colors.orange;
      case MatchStatus.ambiguous:
        return const Color(0xFF86EFAC);
      case MatchStatus.confident:
        return AppTheme.success;
    }
  }

  Color _getCurrentColor() {
    // Priority: user modified > auto updated > original status
    if (transaction.userModified) {
      return AppTheme.success; // Full green for manual updates
    } else if (transaction.autoUpdated) {
      return const Color(0xFFBBF7D0); // Pale green for auto-updates
    }
    // Show original status color if not modified
    return _getStatusColor(originalStatus);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getCurrentColor();

    return ContentBox(
      initiallyMinimized: true,
      expandContent: true,
      previewWidgets: [
        // Status indicator + Vendor name
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
            // Show indicator for auto-updated transactions
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
        // Amount
        Text(
          '${transaction.amount < 0 ? '-' : '+'}${transaction.amount.abs().toStringAsFixed(2)}',
          style: AppTheme.bodyMedium.copyWith(
            color: transaction.amount < 0 ? AppTheme.error : AppTheme.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Account selector
        EnhancedAccountSelector(
          categories: categories,
          selectedAccountId: transaction.suggestedAccount?.id,
          vendorId: transaction.vendorId,
          onAccountSelected: (account) {
            onUpdate(transaction.copyWith(
              account: account.name,
              suggestedAccount: account,
              matchStatus: MatchStatus.confident,
              userModified: true,
              autoUpdated:
                  false, // Clear auto-update flag when manually changed
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
        // Vendor name
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
                        ? AppTheme.error
                        : AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Account selector
        const Text('Account', style: AppTheme.caption),
        const SizedBox(height: 8),
        EnhancedAccountSelector(
          categories: categories,
          selectedAccountId: transaction.suggestedAccount?.id,
          vendorId: transaction.vendorId,
          onAccountSelected: (account) {
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

        // Actions row
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showSplitDialog(context),
              icon: const Icon(Icons.call_split, size: 18),
              label: const Text('Split Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
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
                  activeColor: AppTheme.primaryPink,
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
