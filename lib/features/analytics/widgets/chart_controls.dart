// lib/features/analytics/widgets/chart_controls.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../analytics_viewmodel.dart';

class ChartControls extends StatelessWidget {
  final AnalyticsViewModel viewModel;
  final bool showParticipantToggle;
  final bool showTimeUnitSelector;
  final bool showPeriodNavigation;

  const ChartControls({
    Key? key,
    required this.viewModel,
    this.showParticipantToggle = true,
    this.showTimeUnitSelector = true,
    this.showPeriodNavigation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacingSm,
      runSpacing: AppTheme.spacingSm,
      children: [
        if (showParticipantToggle && viewModel.templateParticipants.isNotEmpty)
          _buildParticipantToggle(context),
        if (showTimeUnitSelector) _buildTimeUnitSelector(context),
        if (showPeriodNavigation) _buildPeriodNavigation(context),
      ],
    );
  }

  Widget _buildParticipantToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildParticipantButton(
            context,
            'All (Avg)',
            viewModel.participantFilter == ParticipantFilter.all,
            () => viewModel.setParticipantFilter(ParticipantFilter.all),
          ),
          ...viewModel.templateParticipants.map((participant) {
            return _buildParticipantButton(
              context,
              participant.firstName ?? 'User',
              viewModel.participantFilter == ParticipantFilter.individual &&
                  viewModel.selectedParticipant?.participantId ==
                      participant.participantId,
              () => viewModel.setParticipantFilter(
                  ParticipantFilter.individual, participant),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildParticipantButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacing2xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? Colors.white : context.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnitSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: viewModel.availableTimeUnits.map((unit) {
          final isSelected = viewModel.timeUnit == unit;
          return GestureDetector(
            onTap: () => viewModel.setTimeUnit(unit),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacing2xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: Text(
                unit.label,
                style: AppTheme.bodySmall.copyWith(
                  color:
                      isSelected ? Colors.white : context.colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => viewModel.navigatePeriod(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            'Period',
            style: AppTheme.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => viewModel.navigatePeriod(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
