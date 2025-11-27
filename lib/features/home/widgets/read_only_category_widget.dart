import 'package:flutter/material.dart';
import '../../../core/models/client_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';

class ReadOnlyCategoryWidget extends StatelessWidget {
  final CategoryData category;

  const ReadOnlyCategoryWidget({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContentBox(
      minimizedHeight: 60,
      initiallyMinimized: true,
      controls: const [], // No controls for read-only
      previewWidgets: [
        // Category color and name
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 32,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
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
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category.accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: Text(
                'No accounts in this category',
                style:
                    AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            )
          else
            ...category.accounts.map((account) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                  horizontal: AppTheme.spacingMd,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.border, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.name,
                      style: AppTheme.bodyMedium,
                    ),
                    Text(
                      '\$${account.budgetAmount.toStringAsFixed(2)}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: AppTheme.spacingMd),

          // Category total footer
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
                  'Total:',
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
}
