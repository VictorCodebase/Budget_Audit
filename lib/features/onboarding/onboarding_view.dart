import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_viewmodel.dart';
import '../../core/widgets/app_header.dart';
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  AppHeader(
                    subtitle: viewModel.isFirstParticipant
                        ? 'Welcome! Let\'s create your admin account'
                        : 'Sign in to continue',
                  ),
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: viewModel.isFirstParticipant
                          ? _buildFirstUserSetup(context, viewModel)
                          : _buildSignInForm(context, viewModel),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFirstUserSetup(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Card
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withOpacity(0.1),
                context.colors.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                size: 64,
                color: context.colors.primary,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Create Admin Account',
                style: AppTheme.h3.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'As the first user, you\'ll be the system administrator with full access to manage budgets and participants.',
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),

        // Setup Form
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Account Details',
                style: AppTheme.h4.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // First Name
              _buildTextField(
                context: context,
                label: 'First Name',
                hint: 'John',
                icon: Icons.person_outline,
                value: viewModel.getFormValue('firstName'),
                onChanged: (value) =>
                    viewModel.updateFormField('firstName', value),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Last Name
              _buildTextField(
                context: context,
                label: 'Last Name (Optional)',
                hint: 'Doe',
                icon: Icons.person_outline,
                value: viewModel.getFormValue('lastName'),
                onChanged: (value) =>
                    viewModel.updateFormField('lastName', value),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Nickname
              _buildTextField(
                context: context,
                label: 'Nickname (Optional)',
                hint: 'How you\'d like to be called',
                icon: Icons.badge_outlined,
                value: viewModel.getFormValue('nickname'),
                onChanged: (value) =>
                    viewModel.updateFormField('nickname', value),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Email
              _buildTextField(
                context: context,
                label: 'Email',
                hint: 'admin@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                value: viewModel.getFormValue('email'),
                onChanged: (value) => viewModel.updateFormField('email', value),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Password
              _buildTextField(
                context: context,
                label: 'Password',
                hint: 'At least 6 characters',
                icon: Icons.lock_outline,
                obscureText: viewModel.passwordObscured,
                value: viewModel.getFormValue('password'),
                onChanged: (value) =>
                    viewModel.updateFormField('password', value),
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.passwordObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: context.colors.textSecondary,
                  ),
                  onPressed: viewModel.onToggleObscure,
                ),
              ),

              if (viewModel.error != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                _buildErrorBox(context, viewModel.error!),
              ],

              const SizedBox(height: AppTheme.spacingXl),

              // Create Account Button
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.createNewParticipant();
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Admin account created successfully!',
                              ),
                              backgroundColor: context.colors.success,
                            ),
                          );
                          // Auto sign-in and navigate
                          final signInSuccess =
                              await viewModel.signInAsParticipant(
                            viewModel.getFormValue('email'),
                            viewModel.getFormValue('password'),
                          );
                          if (signInSuccess && mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/budgeting',
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Create Admin Account'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Back Card
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withOpacity(0.05),
                context.colors.secondary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.login_rounded,
                size: 64,
                color: context.colors.primary,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Welcome Back',
                style: AppTheme.h3.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Sign in to access your budgets and financial data',
                style: AppTheme.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),

        // Sign In Form
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email
              _buildTextField(
                context: context,
                label: 'Email',
                hint: 'your@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                value: viewModel.getFormValue('email'),
                onChanged: (value) => viewModel.updateFormField('email', value),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Password
              _buildTextField(
                context: context,
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: viewModel.passwordObscured,
                value: viewModel.getFormValue('password'),
                onChanged: (value) =>
                    viewModel.updateFormField('password', value),
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.passwordObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: context.colors.textSecondary,
                  ),
                  onPressed: viewModel.onToggleObscure,
                ),
              ),

              if (viewModel.error != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                _buildErrorBox(context, viewModel.error!),
              ],

              const SizedBox(height: AppTheme.spacingXl),

              // Sign In Button
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.signInAsParticipant(
                          viewModel.getFormValue('email'),
                          viewModel.getFormValue('password'),
                        );
                        if (success && mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/budgeting',
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sign In'),
                          const SizedBox(width: AppTheme.spacingXs),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingLg),

        // Help Text
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: context.colors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: context.colors.info.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colors.info,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  'Need to add more participants? Sign in and go to Settings.',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.label.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: context.colors.textSecondary),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBox(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: context.colors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: context.colors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: context.colors.error,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Expanded(
            child: Text(
              error,
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
