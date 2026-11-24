import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/widgets/content_box.dart';
import 'package:budget_audit/features/settings/management_viewmodels/account_management_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ContentBox for a category (v1 account).
class CategoryContentBox extends StatelessWidget {
  final dynamic category;

  const CategoryContentBox({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = context.watch<AccountManagementViewModel>();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        categoryViewModel.getResponsibleParticipantName(
          category.responsibleParticipantId,
        ),
        categoryViewModel.getTransactionCount(category.accountId),
      ]),
      builder: (context, snapshot) {
        final responsibleName =
            snapshot.hasData ? snapshot.data![0] as String? : null;
        final transactionCount =
            snapshot.hasData ? snapshot.data![1] as int : 0;

        final budgetAmount = '\$${category.budgetAmount.toStringAsFixed(2)}';
        final spentAmount = '\$${category.expenditureTotal.toStringAsFixed(2)}';
        final remaining = category.budgetAmount - category.expenditureTotal;
        final remainingAmount = '\$${remaining.toStringAsFixed(2)}';

        return ContentBox(
          minimizedHeight: 40,
          initiallyMinimized: true,
          expandContent: true,
          controls: [
            const ContentBoxControl(
              action: ContentBoxAction.minimize,
            ),
            ContentBoxControl(
              action: ContentBoxAction.delete,
              onPressed: () => _confirmDeleteCategory(
                context,
                categoryViewModel,
                category,
              ),
            ),
          ],
          headerWidgets: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _parseColor(category.colorHex),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      category.accountName,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          previewWidgets: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _parseColor(category.colorHex),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2xs),
                Expanded(
                  child: Text(
                    category.accountName,
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              budgetAmount,
              style: AppTheme.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget',
                        style: AppTheme.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        budgetAmount,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: AppTheme.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        spentAmount,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              category.expenditureTotal > category.budgetAmount
                                  ? context.colors.error
                                  : context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remaining',
                        style: AppTheme.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        remainingAmount,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: remaining < 0
                              ? context.colors.error
                              : context.colors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: LinearProgressIndicator(
                  value: category.budgetAmount > 0
                      ? (category.expenditureTotal / category.budgetAmount)
                          .clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 6,
                  backgroundColor: context.colors.surfaceVariant,
                  color: category.expenditureTotal > category.budgetAmount
                      ? context.colors.error
                      : context.colors.success,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Additional Info
              if (responsibleName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacing2xs),
                    Text(
                      'Responsible: $responsibleName',
                      style: AppTheme.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppTheme.spacing2xs),
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 14,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacing2xs),
                  Text(
                    '$transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'}',
                    style: AppTheme.caption.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(
        int.parse(hexColor.replaceFirst('#', ''), radix: 16) + 0xFF000000,
      );
    } catch (e) {
      return Colors.grey;
    }
  }

  void _confirmDeleteCategory(
    BuildContext context,
    AccountManagementViewModel viewModel,
    dynamic category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.accountName}"?\n\n'
          'This will delete all transactions associated with this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteAccount(category);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Category deleted successfully'),
                    backgroundColor: context.colors.success,
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
}
