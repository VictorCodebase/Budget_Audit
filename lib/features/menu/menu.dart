import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import './menu_viewmodel.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool _isMenuOpen = false;

  void _ensureMenuClosed() {
    if (_isMenuOpen) {
      if (mounted) {
        setState(() {
          _isMenuOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the MenuViewModel instance
    final viewModel = Provider.of<MenuViewModel>(context, listen: false);

    return Consumer<MenuViewModel>(
      builder: (context, viewModel, child) {
        final availableDestinations = viewModel.availableDestinations;

        return PopupMenuButton<String>(
          icon: Icon(
            Icons.menu,
            color:
                _isMenuOpen ? Colors.transparent : context.colors.textPrimary,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          color: context.colors.surface.withOpacity(0.85),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            side: BorderSide(color: context.colors.border, width: 1.0),
          ),
          onOpened: () {
            setState(() {
              _isMenuOpen = true;
            });
          },
          onCanceled: () {
            _ensureMenuClosed();
          },
          onSelected: (String route) {
            _ensureMenuClosed();
            viewModel.menuToggled();

            if (route == 'toggle_theme') {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              return;
            }

            final requiresFullReset =
                viewModel.handleDestinationSelected(route);

            if (requiresFullReset) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                route,
                (Route<dynamic> r) => false,
              );
            } else {
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
