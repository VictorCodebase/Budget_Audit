import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/features/settings/management_viewmodels/participant_management_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Modal for viewing and editing participant details (manager only)
class ParticipantDetailModal extends StatefulWidget {
  final dynamic participant;

  const ParticipantDetailModal({
    Key? key,
    required this.participant,
  }) : super(key: key);

  @override
  State<ParticipantDetailModal> createState() => _ParticipantDetailModalState();
}

class _ParticipantDetailModalState extends State<ParticipantDetailModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with participant data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ParticipantManagementViewModel>();
      viewModel.startEditing(widget.participant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParticipantManagementViewModel>();
    final isCurrentUser = widget.participant.participantId ==
        viewModel.currentUser?.participantId;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.colors.primary.withOpacity(0.1),
                    child: Text(
                      viewModel
                          .getDisplayName(widget.participant)[0]
                          .toUpperCase(),
                      style: AppTheme.h3.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.getDisplayName(widget.participant),
                          style: AppTheme.h3,
                        ),
                        Text(
                          widget.participant.email,
                          style: AppTheme.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      viewModel.cancelEditing();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: context.colors.info.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: context.colors.info,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingXs),
                              Expanded(
                                child: Text(
                                  'This is your account',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: context.colors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // First Name
                      TextFormField(
                        initialValue: viewModel.getFormValue('firstName'),
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: (value) =>
                            viewModel.updateFormField('firstName', value),
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
                        onChanged: (value) =>
                            viewModel.updateFormField('lastName', value),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Nickname
                      TextFormField(
                        initialValue: viewModel.getFormValue('nickname'),
                        decoration: const InputDecoration(
                          labelText: 'Nickname (Optional)',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onChanged: (value) =>
                            viewModel.updateFormField('nickname', value),
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
                        onChanged: (value) =>
                            viewModel.updateFormField('email', value),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                        onChanged: (value) =>
                            viewModel.updateFormField('password', value),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Role Display
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              'Role: ${viewModel.getRoleDisplay(widget.participant)}',
                              style: AppTheme.bodyMedium.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (viewModel.error != null) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSm),
                          decoration: BoxDecoration(
                            color: context.colors.error.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            viewModel.error!,
                            style: AppTheme.bodySmall.copyWith(
                              color: context.colors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delete button (only if not manager and not self)
                  if (!isCurrentUser || !viewModel.isManager)
                    TextButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => _handleDelete(context, viewModel),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.error,
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Save/Cancel buttons
                  Row(
                    children: [
                      TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () {
                                viewModel.cancelEditing();
                                Navigator.pop(context);
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Participant updated successfully'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participant'),
        content: Text(
          'Are you sure you want to delete ${viewModel.getDisplayName(widget.participant)}?',
        ),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await viewModel.deleteParticipant(widget.participant);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Participant deleted successfully'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    }
  }
}
