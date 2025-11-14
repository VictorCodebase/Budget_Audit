import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable header component with logo and subtitle
/// Used across multiple screens for consistent branding
class AppHeader extends StatelessWidget {
  final String? subtitle;
  final double logoHeight;
  final EdgeInsets padding;

  const AppHeader({
    Key? key,
    this.subtitle,
    this.logoHeight = 100,
    this.padding = const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: logoHeight,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: logoHeight,
                width: logoHeight,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'BA',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Budget Audit',
            style: AppTheme.h1.copyWith(color: AppTheme.primaryPink),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}