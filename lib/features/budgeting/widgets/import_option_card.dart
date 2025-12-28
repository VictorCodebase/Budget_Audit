import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ImportOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isEnabled;

  const ImportOptionCard({
    Key? key,
    required this.title,
    required this.description,
    this.onTap,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: AppTheme.h4,
              ),
              const SizedBox(height: AppTheme.spacingXs),

              // Description
              Text(
                description,
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Import button
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: isEnabled ? onTap : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingSm,
                    ),
                  ),
                  child: const Text('Import'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}