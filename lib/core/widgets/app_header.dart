import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/menu/menu.dart';

/// Reusable header component with logo and subtitle
/// Used across multiple screens for consistent branding
class AppHeader extends StatelessWidget {
  final String? subtitle;
  final double logoHeight;
  final EdgeInsets padding;

  AppHeader({
    Key? key,
    this.subtitle,
    this.logoHeight = 200,
    this.padding = const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
        ),
        Positioned(
          top: padding.top / 2, // Adjust position to be vertically centered in the padding area
          left: padding.right, // Align with the left edge of the padding
          child: const Menu(),
        ),
      ],
    );
  }
}
