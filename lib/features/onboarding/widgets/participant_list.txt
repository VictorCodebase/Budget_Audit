
import 'package:budget_audit/core/utils/color_palette.dart';
import 'package:flutter/material.dart';
import '../onboarding_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart' as models;

class ParticipantList extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const ParticipantList({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participants',
            style: AppTheme.h3,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: viewModel.participants.isEmpty
                ? _buildEmptyState(context)
                : _buildParticipantsList(),
          ),
          const SizedBox(height: 16),
          if (viewModel.canProceedDev()) _buildContinueButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: context.colors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No participants yet',
            style: AppTheme.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first participant to get started',
            style: AppTheme.bodySmall.copyWith(
              color: context.colors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return ListView.separated(
      itemCount: viewModel.participants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final participant = viewModel.participants[index];
        return _buildParticipantCard(context, participant);
      },
    );
  }

  Widget _buildParticipantCard(
      BuildContext context,
      models.Participant participant,
      ) {
    final isEditing = viewModel.editingParticipantId == participant.participantId;
    final isOwner = participant.role == models.Role.manager;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEditing ? context.colors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isEditing ? context.colors.primary : context.colors.border,
          width: isEditing ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(participant),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        viewModel.getDisplayName(participant),
                        style: AppTheme.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 8),
                      _buildOwnerBadge(context),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.getFullName(participant),
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  participant.email,
                  style: AppTheme.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.colors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: context.colors.info),
                    const SizedBox(width: 12),
                    Text('Edit', style: AppTheme.bodyMedium),
                  ],
                ),
              ),
              if (!isOwner)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: context.colors.error),
                      const SizedBox(width: 12),
                      Text('Delete', style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                viewModel.startEditingParticipant(participant);
              } else if (value == 'delete') {
                _showDeleteConfirmation(context, participant);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(models.Participant participant) {
    final initials = _getInitials(participant);

    final color = ColorPalette.getRandom();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(models.Participant participant) {
    final firstName = participant.firstName.isNotEmpty
        ? participant.firstName[0].toUpperCase()
        : '';
    final lastName = participant.lastName?.isNotEmpty == true
        ? participant.lastName![0].toUpperCase()
        : '';
    return '$firstName$lastName';
  }

  Widget _buildOwnerBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
      child: Text(
        'Editor, Owner',
        style: AppTheme.caption.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      models.Participant participant,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text('Delete Participant?', style: AppTheme.h4),
        content: Text(
          'Are you sure you want to delete ${viewModel.getDisplayName(participant)}? This action cannot be undone.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.button.copyWith(color: context.colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.removeParticipant(participant.participantId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: Text('Delete', style: AppTheme.button),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
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
