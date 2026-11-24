import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/widgets/content_box.dart';
import 'package:budget_audit/features/settings/management_viewmodels/category_management_viewmodel.dart';
import 'package:budget_audit/features/settings/management_viewmodels/account_management_viewmodel.dart';
import 'package:budget_audit/features/settings/widgets/category_content_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ContentBox for a group (v1 category) with nested categories (v1 accounts).
class GroupContentBox extends StatelessWidget {
  final dynamic group;
  final int budgetId;

  const GroupContentBox({
    Key? key,
    required this.group,
    required this.budgetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupViewModel = context.watch<CategoryManagementViewModel>();

    return FutureBuilder<int>(
      future: groupViewModel.getAccountCount(
        group.categoryId,
        budgetId,
      ),
      builder: (context, snapshot) {
        final categoryCount = snapshot.hasData ? snapshot.data! : 0;

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
                  _confirmDeleteGroup(context, groupViewModel, group),
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
                      color: _parseColor(group.colorHex),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      group.categoryName,
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
                    color: _parseColor(group.colorHex),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    group.categoryName,
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              '$categoryCount ${categoryCount == 1 ? 'category' : 'categories'}',
              style: AppTheme.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Categories',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _buildCategoriesInGroup(context, group.categoryId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesInGroup(BuildContext context, int groupId) {
    final categoryViewModel = context.watch<AccountManagementViewModel>();
    final categories = categoryViewModel.getAccountsForCategory(groupId);
    final isLoading = categoryViewModel.isCategoryLoading(groupId);
    final isLoaded = categoryViewModel.isCategoryLoaded(groupId);

    // Initial load trigger
    if (!isLoaded && !isLoading) {
      Future.microtask(() {
        categoryViewModel.loadAccountsForCategory(budgetId, groupId);
      });
    }

    if (isLoading && categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingSm),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isLoading && categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          child: Text(
            'No categories in this group',
            style: AppTheme.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing2xs),
          child: CategoryContentBox(category: category),
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

  void _confirmDeleteGroup(
    BuildContext context,
    CategoryManagementViewModel viewModel,
    dynamic group,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete "${group.categoryName}"?\n\n'
          'This will delete all categories within this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteCategory(group);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Group deleted successfully'),
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
