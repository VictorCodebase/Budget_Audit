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
    // Group transactions by status (but keep original order within each group)
    final criticalTxns = <ParsedTransaction>[];
    final potentialTxns = <ParsedTransaction>[];
    final ambiguousTxns = <ParsedTransaction>[];
    final confidentTxns = <ParsedTransaction>[];

    for (final txn in viewModel.extractedTransactions) {
      switch (txn.matchStatus) {
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
            title: 'These require your input',
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
            color: const Color(0xFF86EFAC), // Pale green
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
        .where((txn) => txn.suggestedAccount == null || !txn.userModified)
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
    required this.transaction,
    required this.categories,
    required this.originalStatus,
    required this.onUpdate,
    required this.onSplit,
    required this.onDeleteRecommendation,
  });

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.critical:
        return AppTheme.error;
      case MatchStatus.potential:
        return Colors.orange;
      case MatchStatus.ambiguous:
        return const Color(0xFF86EFAC); // Pale green
      case MatchStatus.confident:
        return AppTheme.success;
    }
  }

  Color _getCurrentColor() {
    // If user has modified the transaction, show green
    if (transaction.userModified) {
      return AppTheme.success;
    }
    // Otherwise show original status color
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
              vendorId: null, // No recommendations for split transactions
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

// Enhanced Account Selector with recommendations
class EnhancedAccountSelector extends StatefulWidget {
  final List<CategoryData> categories;
  final String? selectedAccountId;
  final int? vendorId;
  final ValueChanged<AccountData> onAccountSelected;
  final Function(int, int) onDeleteRecommendation;

  const EnhancedAccountSelector({
    Key? key,
    required this.categories,
    required this.selectedAccountId,
    required this.vendorId,
    required this.onAccountSelected,
    required this.onDeleteRecommendation,
  }) : super(key: key);

  @override
  State<EnhancedAccountSelector> createState() =>
      _EnhancedAccountSelectorState();
}

class _EnhancedAccountSelectorState extends State<EnhancedAccountSelector> {
  List<AccountData> _recommendedAccounts = [];
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (widget.vendorId == null) return;

    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      // TODO: Implement in HomeViewModel
      // final recommendations = await viewModel.getVendorRecommendations(widget.vendorId!);
      // For now, mock empty list
      _recommendedAccounts = [];
    } catch (e) {
      _recommendedAccounts = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Flatten all accounts with category information
    final allAccounts = <_AccountWithCategory>[];
    for (final category in widget.categories) {
      for (final account in category.accounts) {
        allAccounts.add(_AccountWithCategory(
          account: account,
          categoryName: category.name,
        ));
      }
    }

    // Sort alphabetically by category, then by account name
    allAccounts.sort((a, b) {
      final catCompare = a.categoryName.compareTo(b.categoryName);
      if (catCompare != 0) return catCompare;
      return a.account.name.compareTo(b.account.name);
    });

    // Find selected account name
    String? selectedName;
    if (widget.selectedAccountId != null) {
      final selected = allAccounts
          .where((a) => a.account.id == widget.selectedAccountId)
          .firstOrNull;
      if (selected != null) {
        selectedName = '${selected.categoryName} - ${selected.account.name}';
      }
    }

    return DropdownButtonFormField<String>(
      value: widget.selectedAccountId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: const Text('Select account'),
      isExpanded: true,
      items: [
        // Recommended section
        if (_recommendedAccounts.isNotEmpty) ...[
          const DropdownMenuItem<String>(
            enabled: false,
            child: Text(
              'RECOMMENDED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          for (final rec in _recommendedAccounts)
            DropdownMenuItem<String>(
              value: rec.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: rec.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rec.name)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      if (widget.vendorId != null) {
                        widget.onDeleteRecommendation(
                          widget.vendorId!,
                          int.parse(rec.id),
                        );
                        setState(() {
                          _recommendedAccounts.remove(rec);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          const DropdownMenuItem<String>(
            enabled: false,
            child: Divider(),
          ),
        ],
        // All accounts
        for (final item in allAccounts)
          DropdownMenuItem<String>(
            value: item.account.id,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.account.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.categoryName} - ${item.account.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          final selected =
              allAccounts.where((a) => a.account.id == value).firstOrNull;
          if (selected != null) {
            widget.onAccountSelected(selected.account);
          }
        }
      },
    );
  }
}

class _AccountWithCategory {
  final AccountData account;
  final String categoryName;

  _AccountWithCategory({
    required this.account,
    required this.categoryName,
  });
}
