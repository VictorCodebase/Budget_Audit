// lib/features/home/widgets/extracted_transactions_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/client_models.dart';
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

    // Sort transactions by attention score (Critical > Potential > Ambiguous > Confident)
    final sortedTransactions =
        List<ParsedTransaction>.from(viewModel.extractedTransactions);
    sortedTransactions
        .sort((a, b) => a.matchStatus.index.compareTo(b.matchStatus.index));

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verify extracted details',
                style: AppTheme.h3,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: viewModel.refreshTransactions,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, viewModel),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete all',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryPink,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Text(
                    'Found ${viewModel.extractedTransactions.length} transactions. '
                    'Review and edit details below before saving.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // List View
          if (_isLoadingCategories)
            const Center(child: CircularProgressIndicator())
          else if (sortedTransactions.isEmpty)
            const Center(child: Text("No transactions found."))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = sortedTransactions[index];
                return _TransactionRow(
                  transaction: transaction,
                  categories: _categories,
                  onUpdate: (updated) => viewModel.updateTransaction(updated),
                  onSplit: () =>
                      _showSplitDialog(context, viewModel, transaction),
                );
              },
            ),
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
              child: const Text('Cancel')),
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

  void _showSplitDialog(BuildContext context, HomeViewModel viewModel,
      ParsedTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => _SplitTransactionDialog(
        transaction: transaction,
        categories: _categories,
        onSplit: (amount, accountName) {
          viewModel.splitTransaction(transaction.id, amount, accountName);
        },
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final ParsedTransaction transaction;
  final List<CategoryData> categories;
  final ValueChanged<ParsedTransaction> onUpdate;
  final VoidCallback onSplit;

  const _TransactionRow({
    required this.transaction,
    required this.categories,
    required this.onUpdate,
    required this.onSplit,
  });

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.critical:
        return AppTheme.error;
      case MatchStatus.potential:
        return Colors.orange;
      case MatchStatus.ambiguous:
        return Colors.amber;
      case MatchStatus.confident:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(transaction.date);
    final statusColor = _getStatusColor(transaction.matchStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Date & Vendor
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.vendorName,
                  style:
                      AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  dateStr,
                  style:
                      AppTheme.caption.copyWith(color: AppTheme.textSecondary),
                ),
                if (transaction.potentialMatches.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Potential match: ${transaction.potentialMatches.first}',
                      style: AppTheme.caption.copyWith(
                          color: Colors.orange, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),

          // Amount
          Expanded(
            flex: 2,
            child: Text(
              '${transaction.amount < 0 ? '-' : '+'}${transaction.amount.abs().toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(
                color:
                    transaction.amount < 0 ? AppTheme.error : AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Account Selector
          Expanded(
            flex: 4,
            child: AccountSelector(
              categories: categories,
              selectedAccountId: transaction.suggestedAccount
                  ?.id, // Or current account ID if we had it stored differently
              onAccountSelected: (account) {
                onUpdate(transaction.copyWith(
                  account: account.name,
                  suggestedAccount: account,
                  matchStatus: MatchStatus
                      .confident, // User manually selected, so confident
                ));
              },
            ),
          ),

          const SizedBox(width: 12),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.call_split, size: 20),
                onPressed: onSplit,
                tooltip: 'Split Transaction',
              ),
              Checkbox(
                value: transaction.useMemory,
                onChanged: (val) {
                  onUpdate(transaction.copyWith(useMemory: val));
                },
                activeColor: AppTheme.primaryPink,
              ),
            ],
          ),
        ],
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

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Split Transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'Original Amount: ${widget.transaction.amount.abs().toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Split Amount',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60, // Fixed height for selector
            child: AccountSelector(
              categories: widget.categories,
              selectedAccountId: _selectedAccount?.id,
              onAccountSelected: (account) {
                setState(() {
                  _selectedAccount = account;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null && amount > 0 && _selectedAccount != null) {
              widget.onSplit(amount, _selectedAccount!.name);
              Navigator.pop(context);
            }
          },
          child: const Text('Split'),
        ),
      ],
    );
  }
}
