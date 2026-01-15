import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/features/settings/management_viewmodels/participant_management_viewmodel.dart';
import 'package:budget_audit/features/settings/widgets/participant_detail_modal.dart';
import 'package:budget_audit/features/settings/widgets/add_participant_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Participant management section
/// Managers can view/edit/delete all participants
/// Regular users can only view participants
class ParticipantSection extends StatelessWidget {
  const ParticipantSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParticipantManagementViewModel>();

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
                            viewModel.isManager
                                ? 'Participants'
                                : 'Team Members',
                            style: AppTheme.h2.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing2xs),
                          Text(
                            viewModel.isManager
                                ? 'Manage all participants in the system'
                                : 'View team members',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (viewModel.isManager) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        ElevatedButton.icon(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _showAddParticipantModal(context),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add Participant'),
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
                            viewModel.isManager
                                ? 'Participants'
                                : 'Team Members',
                            style: AppTheme.h2.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing2xs),
                          Text(
                            viewModel.isManager
                                ? 'Manage all participants in the system'
                                : 'View team members',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (viewModel.isManager)
                        ElevatedButton.icon(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _showAddParticipantModal(context),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add Participant'),
                        ),
                    ],
                  );
          },
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingXl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (viewModel.participants.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Text(
                'No participants found',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          )
        else
          _buildParticipantGrid(context, viewModel),
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

  Widget _buildParticipantGrid(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 110,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: viewModel.participants.length,
      itemBuilder: (context, index) {
        final participant = viewModel.participants[index];
        return _buildParticipantCard(context, viewModel, participant);
      },
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    ParticipantManagementViewModel viewModel,
    dynamic participant,
  ) {
    final isCurrentUser =
        participant.participantId == viewModel.currentUser?.participantId;

    return InkWell(
      onTap: viewModel.isManager
          ? () => _showParticipantDetailModal(context, participant)
          : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isCurrentUser
                ? context.colors.primary.withOpacity(0.5)
                : context.colors.border,
            width: isCurrentUser ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colors.primary.withOpacity(0.1),
                  child: Text(
                    viewModel.getDisplayName(participant)[0].toUpperCase(),
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.getDisplayName(participant),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        participant.email,
                        style: AppTheme.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'You',
                      style: AppTheme.caption.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: participant.role.value == 'manager'
                        ? context.colors.secondary.withOpacity(0.1)
                        : context.colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    viewModel.getRoleDisplay(participant),
                    style: AppTheme.caption.copyWith(
                      color: participant.role.value == 'manager'
                          ? context.colors.secondary
                          : context.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showParticipantDetailModal(BuildContext context, dynamic participant) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: context.read<ParticipantManagementViewModel>(),
        child: ParticipantDetailModal(participant: participant),
      ),
    );
  }

  void _showAddParticipantModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: context.read<ParticipantManagementViewModel>(),
        child: const AddParticipantModal(),
      ),
    );
  }
}
