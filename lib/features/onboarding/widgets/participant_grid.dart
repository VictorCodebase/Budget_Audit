import 'package:budget_audit/core/utils/color_palette.dart';
import 'package:flutter/material.dart';
import '../onboarding_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart' as models;

class ParticipantGrid extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const ParticipantGrid({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participants',
          style: AppTheme.h4,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate number of columns based on available width
            final itemWidth = 140.0;
            final spacing = 12.0;
            final columns =
                ((constraints.maxWidth + spacing) / (itemWidth + spacing))
                    .floor()
                    .clamp(2, 6);

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                // Existing participants
                ...viewModel.participants.map((participant) {
                  return _buildParticipantBox(context, participant);
                }),
                // Add new participant box (only in add participants mode)
                if (viewModel.mode == OnboardingMode.addParticipants)
                  _buildAddParticipantBox(context),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticipantBox(
      BuildContext context, models.Participant participant) {
    final isEditing =
        viewModel.editingParticipantId == participant.participantId;
    final isOwner = participant.role == models.Role.manager;
    final nickname = viewModel.getDisplayName(participant);
    final roleText = isOwner ? 'Editor, Owner' : 'Viewer';

    return GestureDetector(
      onTap: () => _showParticipantActions(context, participant),
      child: Container(
        width: 140,
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isEditing ? context.colors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isEditing ? context.colors.primary : context.colors.border,
            width: isEditing ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            _buildAvatar(participant),
            const SizedBox(height: 12),
            // Nickname
            Text(
              nickname,
              style: AppTheme.label.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isOwner
                    ? context.colors.primary.withOpacity(0.1)
                    : context.colors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: Text(
                roleText,
                style: AppTheme.caption.copyWith(
                  color: isOwner ? context.colors.primary : context.colors.secondary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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

  Widget _buildAddParticipantBox(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: context.colors.border,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Exit edit mode and clear the form to add a new participant
            viewModel.cancelEditing();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add New',
                style: AppTheme.label.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParticipantActions(
      BuildContext context, models.Participant participant) {
    final isOwner = participant.role == models.Role.manager;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildAvatar(participant),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.getDisplayName(participant),
                        style: AppTheme.h4,
                      ),
                      Text(
                        viewModel.getFullName(participant),
                        style: AppTheme.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Actions
            ListTile(
              leading: Icon(Icons.edit_outlined, color: context.colors.info),
              title: Text('Edit', style: AppTheme.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                viewModel.startEditingParticipant(participant);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            if (!isOwner)
              ListTile(
                leading: Icon(Icons.delete_outline, color: context.colors.error),
                title: Text('Delete', style: AppTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, participant);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
          ],
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
}
