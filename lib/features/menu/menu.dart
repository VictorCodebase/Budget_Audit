import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import './menu_viewmodel.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the MenuViewModel instance (already provided higher up in AppHeader)
    final viewModel = Provider.of<MenuViewModel>(context, listen: false);

    // We listen to the VM via Consumer below to update the menu items
    // but the onSelected callback should use the non-listening instance.

    return Consumer<MenuViewModel>(
      builder: (context, viewModel, child) {
        final availableDestinations = viewModel.availableDestinations;

        return PopupMenuButton<String>(
          icon: Icon(
            Icons.menu,
            color: context.colors.textPrimary,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          // Glassmorphism: Semi-transparent surface
          color: context.colors.surface.withOpacity(0.85),
          elevation: 0, // Remove default shadow for cleaner glass look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            side: BorderSide(color: context.colors.border, width: 1.0),
          ),
          onSelected: (String route) {
            viewModel.menuToggled();

            if (route == 'toggle_theme') {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              return;
            }

            // ⭐️ LOGIC IS NOW IN THE VIEW MODEL ⭐️
            // Call the VM method to execute business logic (like signing out)
            final requiresFullReset =
                viewModel.handleDestinationSelected(route);

            // UI's sole responsibility: execute the navigation requested by the VM logic
            if (requiresFullReset) {
              // Sign Out: Pop all routes and push the sign-out route
              Navigator.of(context).pushNamedAndRemoveUntil(
                route,
                (Route<dynamic> r) => false,
              );
            } else {
              // Standard Navigation: Navigate to the selected route
              Navigator.of(context).pushNamed(route);
            }
          },
          itemBuilder: (BuildContext context) {
            return availableDestinations.map((destination) {
              return PopupMenuItem<String>(
                value: destination.route,
                child: Row(
                  children: [
                    Icon(destination.icon, color: context.colors.textPrimary),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      destination.label,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
              ..add(
                PopupMenuItem<String>(
                  value: 'toggle_theme',
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      final isDark = themeProvider.isDarkMode;
                      return Row(
                        children: [
                          Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: context.colors.textPrimary,
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Text(
                            isDark
                                ? 'Switch to Light Mode'
                                : 'Switch to Dark Mode',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
          },
        );
      },
    );
  }
}
