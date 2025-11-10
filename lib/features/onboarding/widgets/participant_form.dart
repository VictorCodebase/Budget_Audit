
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
          border: Border.all(color: AppTheme.border, width: 1),
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
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildForm(context),
            if (viewModel.error != null) ...[
              const SizedBox(height: 16),
              _buildError(),
            ],
            const SizedBox(height: 24),
            _buildSubmitButton(context),
          ],
        ),
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
                label: 'First Name',
                hint: 'Stevie',
                isRequired: true,
                value: viewModel.getFormValue('firstName'),
                onChanged: (value) => viewModel.updateFormField('firstName', value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Second Name',
                hint: 'Doe',
                value: viewModel.getFormValue('lastName'),
                onChanged: (value) => viewModel.updateFormField('lastName', value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Preferred Nickname',
          hint: 'JohnieD',
          value: viewModel.getFormValue('nickname'),
          onChanged: (value) => viewModel.updateFormField('nickname', value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          hint: 'johndoe@mail.com',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          value: viewModel.getFormValue('email'),
          onChanged: (value) => viewModel.updateFormField('email', value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Password',
          hint: '••••',
          isRequired: true,
          obscureText: true,
          value: viewModel.getFormValue('password'),
          onChanged: (value) => viewModel.updateFormField('password', value),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    bool isRequired = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.label.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: AppTheme.label.copyWith(
                  color: AppTheme.error,
                ),
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
              color: AppTheme.textTertiary,
            ),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.primaryPink, width: 2),
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
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.error!,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

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
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
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
}
