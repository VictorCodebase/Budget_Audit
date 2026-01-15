import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/features/settings/management_viewmodels/participant_management_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Modal for adding a new participant (manager only)
class AddParticipantModal extends StatefulWidget {
  const AddParticipantModal({Key? key}) : super(key: key);

  @override
  State<AddParticipantModal> createState() => _AddParticipantModalState();
}

class _AddParticipantModalState extends State<AddParticipantModal> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Clear form when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ParticipantManagementViewModel>();
      viewModel.cancelEditing(); // This clears the form
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParticipantManagementViewModel>();

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
                  Icon(
                    Icons.person_add,
                    color: context.colors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Text(
                      'Add New Participant',
                      style: AppTheme.h3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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

                      // Password
                      TextFormField(
                        initialValue: viewModel.getFormValue('password'),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.passwordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: viewModel.togglePasswordObscured,
                          ),
                        ),
                        obscureText: viewModel.passwordObscured,
                        onChanged: (value) =>
                            viewModel.updateFormField('password', value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Info box
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
                                'New participants will be created with "Participant" role',
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.colors.info,
                                ),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _handleAdd(context, viewModel),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Participant'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAdd(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
  ) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await viewModel.addParticipant();
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Participant added successfully'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    }
  }
}
