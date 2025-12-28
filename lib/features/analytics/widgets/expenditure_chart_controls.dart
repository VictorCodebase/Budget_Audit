// lib/features/analytics/widgets/expenditure_chart_controls.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../analytics_viewmodel.dart';

class ExpenditureChartControls extends StatelessWidget {
  const ExpenditureChartControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final isNarrowScreen = mediaQuery.size.width < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: isNarrowScreen
          ? Column(
              children: [
                _buildParticipantToggle(context, viewModel),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: [
                    Expanded(child: _buildTimeUnitSelector(context, viewModel)),
                    const SizedBox(width: AppTheme.spacingSm),
                    _buildNavigationButtons(context, viewModel),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildParticipantToggle(context, viewModel)),
                const SizedBox(width: AppTheme.spacingMd),
                _buildTimeUnitSelector(context, viewModel),
                const SizedBox(width: AppTheme.spacingMd),
                _buildNavigationButtons(context, viewModel),
              ],
            ),
    );
  }

  Widget _buildParticipantToggle(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          size: 16,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacing2xs),
        Text(
          'View:',
          style: AppTheme.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: context.colors.border),
            ),
            child: DropdownButton<String>(
              value: viewModel.participantFilter == ParticipantFilter.all
                  ? 'all'
                  : viewModel.selectedParticipant?.participantId.toString() ??
                      'all',
              isExpanded: true,
              underline: const SizedBox.shrink(),
              isDense: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: context.colors.textPrimary,
                size: 20,
              ),
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textPrimary,
              ),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    'All (Average)',
                    style: AppTheme.bodySmall,
                  ),
                ),
                ...viewModel.templateParticipants.map((participant) {
                  return DropdownMenuItem(
                    value: participant.participantId.toString(),
                    child: Text(
                      participant.firstName,
                      style: AppTheme.bodySmall,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                if (value == 'all') {
                  viewModel.setParticipantFilter(ParticipantFilter.all);
                } else {
                  final participant = viewModel.templateParticipants.firstWhere(
                    (p) => p.participantId.toString() == value,
                  );
                  viewModel.setParticipantFilter(
                    ParticipantFilter.individual,
                    participant,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeUnitSelector(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacing2xs),
        Text(
          'Period:',
          style: AppTheme.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: context.colors.border),
          ),
          child: DropdownButton<TimeUnit>(
            value: viewModel.timeUnit,
            underline: const SizedBox.shrink(),
            isDense: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: context.colors.textPrimary,
              size: 20,
            ),
            style: AppTheme.bodySmall.copyWith(
              color: context.colors.textPrimary,
            ),
            items: viewModel.availableTimeUnits.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(
                  unit.label,
                  style: AppTheme.bodySmall,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.setTimeUnit(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    AnalyticsViewModel viewModel,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavButton(
          context,
          Icons.chevron_left,
          () => viewModel.navigatePeriod(-1),
        ),
        const SizedBox(width: AppTheme.spacing2xs),
        _buildNavButton(
          context,
          Icons.chevron_right,
          () => viewModel.navigatePeriod(1),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: context.colors.border),
        ),
        child: Icon(
          icon,
          size: 20,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}
