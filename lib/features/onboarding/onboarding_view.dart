import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_viewmodel.dart';
import 'widgets/participant_form.dart';
import 'widgets/participant_list.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 100,
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
          const SizedBox(height: 8),
          Consumer<OnboardingViewModel>(
            builder: (context, viewModel, _) {
              return Text(
                viewModel.isFirstParticipant
                    ? 'Welcome! Let\'s set up your account'
                    : 'Manage participants or sign in',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ],
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
                        if (viewModel.canProceed()) _buildContinueButton(viewModel),
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
                          if (viewModel.canProceed()) _buildContinueButton(viewModel),
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border, width: 1),
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
              onTap: () => viewModel.switchMode(OnboardingMode.signInAsParticipant),
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
              ? const Border(
            bottom: BorderSide(
              color: AppTheme.primaryPink,
              width: 3,
            ),
          )
              : null,
        ),
        child: Text(
          label,
          style: AppTheme.label.copyWith(
            color: isSelected ? AppTheme.primaryPink : AppTheme.textSecondary,
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
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue to Budgeting', style: AppTheme.button),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}