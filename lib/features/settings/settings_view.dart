import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/widgets/app_header.dart';
import 'package:budget_audit/core/widgets/content_box.dart';
import 'package:budget_audit/features/settings/settings_viewmodel.dart';

import 'package:budget_audit/features/settings/widgets/profile_section.dart';
import 'package:budget_audit/features/settings/widgets/participant_section.dart';
import 'package:budget_audit/features/settings/widgets/template_section.dart';
import 'package:budget_audit/features/settings/widgets/vendor_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _SettingsViewContent();
  }
}

class _SettingsViewContent extends StatelessWidget {
  const _SettingsViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(
                subtitle: 'Manage your account, budgets, and preferences',
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Section (always visible)
                    const ProfileSection(),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Participant Management Section
                    const ParticipantSection(),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Budget Management Header
                    Text(
                      'Budget Management',
                      style: AppTheme.h2.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      settingsViewModel.isManager
                          ? 'Manage all templates, categories, and accounts'
                          : 'View and manage your budgets',
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Template/Category/Account Section
                    const TemplateSection(),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Vendor Management Section
                    const VendorSection(),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Sign Out Button
                    if (settingsViewModel.isSignedIn)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: settingsViewModel.isLoading
                              ? null
                              : () =>
                                  _handleSignOut(context, settingsViewModel),
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingXl,
                              vertical: AppTheme.spacingSm,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await viewModel.signOut();
      if (success && context.mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }
}
