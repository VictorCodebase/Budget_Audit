import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_viewmodel.dart';
import '../../core/widgets/app_header.dart';
import 'widgets/participant_form.dart';

import 'widgets/participant_grid.dart';
import 'widgets/sign_in_form.dart';
import '../../core/theme/app_theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Consumer<OnboardingViewModel>(
                  builder: (context, viewModel, _) {
                    return AppHeader(
                      subtitle: viewModel.isFirstParticipant
                          ? 'Welcome! Let\'s set up your account'
                          : 'Manage participants or sign in',
                    );
                  },
                ),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Use column layout for screens smaller than 900px width
            final useColumnLayout = constraints.maxWidth < 900;

            if (useColumnLayout) {
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildModeTabs(viewModel),
                        const SizedBox(height: 24),
                        // Participants Grid first
                        if (viewModel.participants.isNotEmpty ||
                            viewModel.mode == OnboardingMode.addParticipants)
                          ParticipantGrid(viewModel: viewModel),
                        const SizedBox(height: 24),
                        // Form below
                        viewModel.mode == OnboardingMode.addParticipants
                            ? ParticipantForm(viewModel: viewModel)
                            : SignInForm(viewModel: viewModel),
                        const SizedBox(height: 24),
                        // Continue Button
                        if (viewModel.canProceedDev())
                          _buildContinueButton(viewModel),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Form
                  Expanded(
                    flex: 3,
                    child: _buildLeftPanel(viewModel),
                  ),
                  // Right side - Participants Grid
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: ParticipantGrid(viewModel: viewModel),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (viewModel.canProceedDev())
                            _buildContinueButton(viewModel),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildLeftPanel(OnboardingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildModeTabs(viewModel),
          const SizedBox(height: 32),
          Expanded(
            child: viewModel.mode == OnboardingMode.addParticipants
                ? ParticipantForm(viewModel: viewModel)
                : SignInForm(viewModel: viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs(OnboardingViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              label: 'Add Participants',
              isSelected: viewModel.mode == OnboardingMode.addParticipants,
              onTap: () => viewModel.switchMode(OnboardingMode.addParticipants),
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: 'Sign in as a participant',
              isSelected: viewModel.mode == OnboardingMode.signInAsParticipant,
              onTap: () =>
                  viewModel.switchMode(OnboardingMode.signInAsParticipant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: context.colors.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTheme.label.copyWith(
            color: isSelected
                ? context.colors.textPrimary
                : context.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContinueButton(OnboardingViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            viewModel.getNextRoute(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue to Budgeting (Dev env only)',
                style: AppTheme.button),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
