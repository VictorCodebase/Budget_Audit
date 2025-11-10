
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_viewmodel.dart';
import 'widgets/participant_form.dart';
import 'widgets/participant_list.dart';
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
            'assets/images/budget_audit_logo.png',
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
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
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Form
            Expanded(
              flex: 3,
              child: _buildLeftPanel(viewModel),
            ),
            // Right side - Participants list
            Expanded(
              flex: 2,
              child: ParticipantList(viewModel: viewModel),
            ),
          ],
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
}
