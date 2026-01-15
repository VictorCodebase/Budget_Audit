import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/widgets/content_box.dart';
import 'package:budget_audit/features/settings/management_viewmodels/category_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/account_management_viewmodel.dart';
import 'package:budget_audit/features/settings/widgets/account_content_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ContentBox for a category with nested accounts
class CategoryContentBox extends StatelessWidget {
  final dynamic category;
  final int templateId;

  const CategoryContentBox({
    Key? key,
    required this.category,
    required this.templateId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = context.watch<CategoryManagementViewModel>();

    return FutureBuilder<int>(
      future: categoryViewModel.getAccountCount(
        category.categoryId,
        templateId,
      ),
      builder: (context, snapshot) {
        final accountCount = snapshot.hasData ? snapshot.data! : 0;

        return ContentBox(
          minimizedHeight: 50,
          initiallyMinimized: true,
          expandContent: false,
          controls: [
            const ContentBoxControl(
              action: ContentBoxAction.minimize,
            ),
            ContentBoxControl(
              action: ContentBoxAction.delete,
              onPressed: () =>
                  _confirmDeleteCategory(context, categoryViewModel, category),
            ),
          ],
          headerWidgets: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _parseColor(category.colorHex),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      category.categoryName,
                      style: AppTheme.bodyMedium.copyWith(
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
                    category.categoryName,
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              '$accountCount ${accountCount == 1 ? 'account' : 'accounts'}',
              style: AppTheme.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Accounts',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildAccountsForCategory(context, category.categoryId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountsForCategory(BuildContext context, int categoryId) {
    final accountViewModel = context.watch<AccountManagementViewModel>();
    final accounts = accountViewModel.getAccountsForCategory(categoryId);
    final isLoading = accountViewModel.isCategoryLoading(categoryId);
    final isLoaded = accountViewModel.isCategoryLoaded(categoryId);

    // Initial load trigger
    if (!isLoaded && !isLoading) {
      Future.microtask(() {
        accountViewModel.loadAccountsForCategory(templateId, categoryId);
      });
    }

    if (isLoading && accounts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingSm),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isLoading && accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          child: Text(
            'No accounts in this category',
            style: AppTheme.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: accounts.map((account) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing2xs),
          child: AccountContentBox(account: account),
        );
      }).toList(),
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
    CategoryManagementViewModel viewModel,
    dynamic category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.categoryName}"?\n\n'
          'This will delete all accounts within this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteCategory(category);
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
