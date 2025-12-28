import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/menu/menu.dart';

/// Reusable header component with logo and subtitle
/// Used across multiple screens for consistent branding
class AppHeader extends StatelessWidget {
  final String? subtitle;
  final double? logoHeight;
  final EdgeInsets padding;

  const AppHeader({
    Key? key,
    this.subtitle,
    this.logoHeight,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    // Calculate max height (1/8th of screen)
    final maxHeaderHeight = screenHeight / 4;
    // Use provided logoHeight or calculate based on constraints, ensuring it's not too large
    final effectiveLogoHeight = logoHeight ?? (maxHeaderHeight * 0.6);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: effectiveLogoHeight,
                cacheHeight:
                    (effectiveLogoHeight * mediaQuery.devicePixelRatio).round(),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: effectiveLogoHeight,
                    width: effectiveLogoHeight,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(effectiveLogoHeight * 0.2),
                    ),
                    child: Center(
                      child: Text(
                        'BA',
                        style: TextStyle(
                          fontSize: effectiveLogoHeight * 0.4,
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const Positioned(
          top: 12,
          left: 24,
          child: Menu(),
        ),
      ],
    );
  }
}
