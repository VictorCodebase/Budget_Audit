import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/features/settings/management_viewmodels/participant_management_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Profile section for editing current user's information
class ProfileSection extends StatefulWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParticipantManagementViewModel>();
    final currentUser = viewModel.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            return isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: AppTheme.h2.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing2xs),
                          Text(
                            'Manage your personal information',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!_isEditing) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        ElevatedButton.icon(
                          onPressed: () {
                            viewModel.startEditing(currentUser);
                            setState(() => _isEditing = true);
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: AppTheme.h2.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing2xs),
                          Text(
                            'Manage your personal information',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!_isEditing)
                        ElevatedButton.icon(
                          onPressed: () {
                            viewModel.startEditing(currentUser);
                            setState(() => _isEditing = true);
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Profile'),
                        ),
                    ],
                  );
          },
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colors.border),
          ),
          child: _isEditing
              ? _buildEditForm(context, viewModel)
              : _buildViewMode(context, viewModel, currentUser),
        ),
        if (viewModel.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            child: Text(
              viewModel.error!,
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildViewMode(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
    dynamic currentUser,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          'Name',
          viewModel.getFullName(currentUser),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildInfoRow(
          context,
          'Display Name',
          viewModel.getDisplayName(currentUser),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildInfoRow(
          context,
          'Email',
          currentUser.email,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildInfoRow(
          context,
          'Role',
          viewModel.getRoleDisplay(currentUser),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Name
          TextFormField(
            initialValue: viewModel.getFormValue('firstName'),
            decoration: const InputDecoration(
              labelText: 'First Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) => viewModel.updateFormField('firstName', value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Last Name
          TextFormField(
            initialValue: viewModel.getFormValue('lastName'),
            decoration: const InputDecoration(
              labelText: 'Last Name (Optional)',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) => viewModel.updateFormField('lastName', value),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Nickname
          TextFormField(
            initialValue: viewModel.getFormValue('nickname'),
            decoration: const InputDecoration(
              labelText: 'Nickname (Optional)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            onChanged: (value) => viewModel.updateFormField('nickname', value),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Email
          TextFormField(
            initialValue: viewModel.getFormValue('email'),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => viewModel.updateFormField('email', value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Password (optional when editing)
          TextFormField(
            initialValue: viewModel.getFormValue('password'),
            decoration: InputDecoration(
              labelText: 'New Password (Optional)',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.passwordObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: viewModel.togglePasswordObscured,
              ),
              helperText: 'Leave blank to keep current password',
            ),
            obscureText: viewModel.passwordObscured,
            onChanged: (value) => viewModel.updateFormField('password', value),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        viewModel.cancelEditing();
                        setState(() => _isEditing = false);
                      },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => _handleSave(context, viewModel),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
  ) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await viewModel.updateParticipant();
      if (success && mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    }
  }
}
