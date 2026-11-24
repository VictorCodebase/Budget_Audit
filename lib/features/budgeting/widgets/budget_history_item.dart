import 'package:flutter/material.dart';
import '../../../core/models/models.dart' as models;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';

class BudgetHistoryItem extends StatelessWidget {
  final models.Template budget;
  final double totalBudget;
  final bool isCurrent;
  final VoidCallback onAdopt;
  final VoidCallback onDelete;

  const BudgetHistoryItem({
    Key? key,
    required this.budget,
    this.totalBudget = 0.0,
    this.isCurrent = false,
    required this.onAdopt,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContentBox(
      minimizedHeight: 60,
      initiallyMinimized: true,
      controls: [
        const ContentBoxControl(
          action: ContentBoxAction.minimize,
        ),
        if (!isCurrent)
          ContentBoxControl(
            action: ContentBoxAction.delete,
            onPressed: onDelete,
          ),
      ],
      previewWidgets: [
        Text(
          budget.templateName,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '\$${totalBudget.toStringAsFixed(2)}',
          style: AppTheme.bodyMedium.copyWith(
            color: context.colors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: context.colors.success,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Text(
              'Current',
              style: AppTheme.caption.copyWith(color: context.colors.primary),
            ),
          ),
      ],
      headerWidgets: [
        _buildInfoRow(
          context,
          'Date Created',
          _formatDate(budget.dateCreated),
        ),
        _buildInfoRow(
          context,
          'Total Budget',
          '\$${totalBudget.toStringAsFixed(2)}',
        ),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current budget badge
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: context.colors.success, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: context.colors.success,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    'Currently Active Budget',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Adopt button (only if not current)
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdopt,
                child: const Text('Use Budget'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: AppTheme.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
