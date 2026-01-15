import 'package:flutter/material.dart';
import '../onboarding_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class ParticipantForm extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const ParticipantForm({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

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
              viewModel.editingParticipantId != null
                  ? 'Edit Participant'
                  : 'Add Participant',
              style: AppTheme.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Participants are individuals whose financial statements will be included in the budgeting',
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (viewModel.isFirstParticipant) ...[
              _buildAdminNotification(context),
              const SizedBox(height: 24),
            ],
            _buildForm(context),
            if (viewModel.error != null) ...[
              const SizedBox(height: 16),
              _buildError(context),
            ],
            const SizedBox(height: 24),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEditModeHeader(
      BuildContext context, OnboardingViewModel viewModel) {
    if (!viewModel.isEditMode) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Editing participant',
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => viewModel.cancelEditing(),
            child: Text(
              'Cancel',
              style: AppTheme.button.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context: context,
                label: 'First Name',
                hint: 'Mark',
                isRequired: true,
                value: viewModel.getFormValue('firstName'),
                onChanged: (value) =>
                    viewModel.updateFormField('firstName', value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                context: context,
                label: 'Second Name',
                hint: 'Kithinji',
                value: viewModel.getFormValue('lastName'),
                onChanged: (value) =>
                    viewModel.updateFormField('lastName', value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          label: 'Preferred Nickname',
          hint: 'VictorCodebase',
          value: viewModel.getFormValue('nickname'),
          onChanged: (value) => viewModel.updateFormField('nickname', value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          label: 'Email',
          hint: 'yourmail@mail.com',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          value: viewModel.getFormValue('email'),
          onChanged: (value) => viewModel.updateFormField('email', value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          label: viewModel.isEditMode
              ? 'Password (leave blank to keep current)'
              : 'Password',
          hint: viewModel.isEditMode
              ? 'Enter new password or leave blank'
              : '••••',
          isRequired: !viewModel.isEditMode,
          obscureText: viewModel.passwordObscured,
          showVisibilityToggle: true,
          onToggleObscure: viewModel.onToggleObscure,
          value: viewModel.getFormValue('password') ?? '',
          onChanged: (value) => viewModel.updateFormField('password', value),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    bool isRequired = false,
    bool obscureText = false,
    bool showVisibilityToggle = false,
    TextInputType? keyboardType,
    required String value,
    required ValueChanged<String> onChanged,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.label.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: AppTheme.label.copyWith(
                  color: context.colors.error,
                ),
              ),
            if (showVisibilityToggle)
              IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: viewModel.onToggleObscure,
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: context.colors.textTertiary,
            ),
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

  Widget _buildError(BuildContext context) {
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
              viewModel.error!,
              style: AppTheme.bodySmall.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget _buildSubmitButton(BuildContext context) {
    final isEditing = viewModel.editingParticipantId != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () async {
                final success = isEditing
                    ? await viewModel.updateExistingParticipant()
                    : await viewModel.createNewParticipant();

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Participant updated successfully'
                            : 'Participant created successfully',
                      ),
                      backgroundColor: context.colors.success,
                    ),
                  );
                }
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
        child: viewModel.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing ? 'Update Participant' : 'Create new Participant',
                style: AppTheme.button,
              ),
      ),
    );
  }

  Widget _buildAdminNotification(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined,
              color: context.colors.secondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Role',
                  style: AppTheme.label.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'As the first participant, you will be assigned the Admin role with full access to manage the budget.',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
