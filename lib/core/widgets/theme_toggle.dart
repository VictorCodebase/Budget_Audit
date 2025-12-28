import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: context.colors.textPrimary,
            size: 28,
          ),
          tooltip: isDark ? 'Switch from Light Mode' : 'Switch from Dark Mode',
        );
      },
    );
  }
}
