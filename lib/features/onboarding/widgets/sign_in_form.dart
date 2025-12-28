import 'package:flutter/material.dart';
import '../onboarding_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class SignInForm extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const SignInForm({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: context.colors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign In',
              style: AppTheme.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your credentials to access your account',
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'johndoe@mail.com',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
              obscureText: true,
              icon: Icons.lock_outline,
            ),
            if (widget.viewModel.error != null) ...[
              const SizedBox(height: 16),
              _buildError(),
            ],
            const SizedBox(height: 24),
            _buildSignInButton(),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  widget.viewModel.switchMode(OnboardingMode.addParticipants);
                },
                child: Text(
                  'Don\'t have an account? Add participant',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? icon,
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: context.colors.textTertiary,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: context.colors.textSecondary)
                : null,
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: context.colors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: context.colors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.colors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.viewModel.error!,
              style: AppTheme.bodySmall.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.viewModel.isLoading
            ? null
            : () async {
          // signInAsParticipant now returns bool, not Participant?
          final success = await widget.viewModel.signInAsParticipant(
            _emailController.text.trim(),
            _passwordController.text,
          );

          if (success && mounted) {
            // Navigate to home or budgeting page
            Navigator.pushReplacementNamed(
              context,
              widget.viewModel.getNextRoute(),
            );
          }
          // If success is false, the error is already displayed via viewModel.error
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          elevation: 0,
        ),
        child: widget.viewModel.isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Sign In',
          style: AppTheme.button,
        ),
      ),
    );
  }
}