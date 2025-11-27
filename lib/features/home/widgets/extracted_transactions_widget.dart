// lib/features/home/widgets/extracted_transactions_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../home_viewmodel.dart';

class ExtractedTransactionsWidget extends StatelessWidget {
  const ExtractedTransactionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

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
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, viewModel),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete all',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
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

          // Transactions table
          _buildTransactionsTable(viewModel),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(HomeViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: AppTheme.spacingLg,
        headingRowColor: MaterialStateProperty.all(AppTheme.surface),
        border: TableBorder.all(
          color: AppTheme.border,
          width: 1,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        columns: const [
          DataColumn(label: Text('Vendor')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Account')),
          DataColumn(label: Text('Use Memory')),
        ],
        rows: viewModel.extractedTransactions.map((transaction) {
          // Group transactions by date
          final dateStr = DateFormat('dd/MM/yyyy').format(transaction.date);

          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction.vendorName,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: transaction.amount < 0
                        ? AppTheme.error.withOpacity(0.1)
                        : AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Text(
                    '${transaction.amount < 0 ? '-' : '+'}${transaction.amount.abs().toStringAsFixed(2)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: transaction.amount < 0
                          ? AppTheme.error
                          : AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  transaction.category ?? 'Food and Shopping',
                  style: AppTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  transaction.account ?? 'SuperMarket',
                  style: AppTheme.bodySmall,
                ),
              ),
              DataCell(
                Checkbox(
                  value: transaction.useMemory,
                  onChanged: (value) {
                    viewModel.toggleUseMemory(transaction.id);
                  },
                  activeColor: AppTheme.primaryPink,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HomeViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transactions'),
        content: const Text(
          'This will remove all extracted transactions. '
          'You can run the audit again to re-extract them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
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
