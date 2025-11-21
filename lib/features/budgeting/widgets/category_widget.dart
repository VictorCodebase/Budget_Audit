import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../../core/models/client_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';
import '../budgeting_viewmodel.dart';
import 'account_row.dart';
import 'participant_avatar.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryData category;

  const CategoryWidget({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BudgetingViewModel>();

    return ContentBox(
      minimizedHeight: 60,
      initiallyMinimized: false,
      controls: [
        ContentBoxControl(
          action: ContentBoxAction.minimize,
          onPressed: () {},
        ),
        ContentBoxControl(
          action: ContentBoxAction.delete,
          onPressed: () => _confirmDelete(context, viewModel),
        ),
      ],
      previewWidgets: [
        // Category color and name
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Flexible(
              child: Text(
                category.name,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Total budget
        Text(
          'Total: \$${category.totalBudget.toStringAsFixed(2)}',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        // Participants (if any)
        if (category.allParticipants.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: category.allParticipants.take(3).map((participant) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ParticipantAvatar(
                  participant: participant,
                  size: 24,
                ),
              );
            }).toList(),
          ),
      ],
      headerWidgets: [
        // Color picker
        _buildColorPicker(context, viewModel),
        // Category name editor
        _buildCategoryNameEditor(context, viewModel),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Validation error banner
          if (category.validationError != null)
            Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.error, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      category.validationError!,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),

          // Account rows
          if (category.accounts.isNotEmpty)
            ...category.accounts.map((account) {
              return AccountRow(
                key: ValueKey(account.id),
                categoryId: category.id,
                account: account,
              );
            }),

          const SizedBox(height: AppTheme.spacingXs),

          // Add account button
          InkWell(
            onTap: () => viewModel.addAccount(category.id),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryPink,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.primaryPink,
                  ),
                  const SizedBox(width: AppTheme.spacing2xs),
                  Text(
                    'Add Account',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Category total
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budgeted in Category:',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${category.totalBudget.toStringAsFixed(2)}',
                  style: AppTheme.h4.copyWith(
                    color: AppTheme.primaryPink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context, BudgetingViewModel viewModel) {
    return InkWell(
      onTap: () => _showColorPicker(context, viewModel),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: category.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryNameEditor(BuildContext context, BudgetingViewModel viewModel) {
    return InkWell(
      onTap: () => _showNameEditor(context, viewModel),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border, width: 1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                category.name,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTheme.spacing2xs),
            const Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, BudgetingViewModel viewModel) {
    Color pickerColor = category.color;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.updateCategoryColor(category.id, pickerColor);
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _showNameEditor(BuildContext context, BudgetingViewModel viewModel) {
    final controller = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                viewModel.updateCategoryName(category.id, value.trim());
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  viewModel.updateCategoryName(category.id, controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, BudgetingViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This will also delete all accounts in this category.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteCategory(category.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}