import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart' as models;
import '../budgeting_viewmodel.dart';
import '../../../core/utils/color_palette.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetingViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              TextField(
                onChanged: viewModel.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Enter a keyword to search with',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: viewModel.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => viewModel.setSearchQuery(''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Search type buttons (non-functional as per design)
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       _buildFilterChip(
              //         context,
              //         label: 'Search Categories',
              //         icon: Icons.search,
              //         isActive: false,
              //         onTap: () {},
              //       ),
              //       const SizedBox(width: AppTheme.spacingXs),
              //       _buildFilterChip(
              //         context,
              //         label: 'Search Accounts',
              //         icon: Icons.account_balance_wallet,
              //         isActive: false,
              //         onTap: () {},
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: AppTheme.spacingSm),

              // Filter and sort options
              Row(
                children: [
                  Icon(Icons.filter_list,
                      size: 20, color: context.colors.textSecondary),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSortButton(
                            context,
                            label: 'Order by Name (A-Z)',
                            filterType: FilterType.name,
                            viewModel: viewModel,
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          _buildSortButton(
                            context,
                            label: viewModel.sortOrder == SortOrder.asc
                                ? 'Order by Total Budget (Low-High)'
                                : 'Order by Total Budget (High-Low)',
                            filterType: FilterType.totalBudget,
                            viewModel: viewModel,
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          _buildParticipantFilter(context, viewModel),
                          const SizedBox(width: AppTheme.spacingXs),
                          _buildColorFilter(context, viewModel),
                          const SizedBox(width: AppTheme.spacingXs),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isActive ? context.colors.primary : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacing2xs),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isActive
                    ? context.colors.primary
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(
    BuildContext context, {
    required String label,
    required FilterType filterType,
    required BudgetingViewModel viewModel,
  }) {
    final isActive = viewModel.currentFilter == filterType;

    return InkWell(
      onTap: () {
        viewModel.setFilter(filterType, order: SortOrder.asc);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isActive ? context.colors.primary : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isActive
                    ? context.colors.primary
                    : context.colors.textSecondary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: AppTheme.spacing2xs),
              Icon(
                viewModel.sortOrder == SortOrder.asc
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 14,
                color: context.colors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantFilter(
      BuildContext context, BudgetingViewModel viewModel) {
    final hasFilter = viewModel.filterParticipant != null;

    return PopupMenuButton<Object?>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: hasFilter
              ? context.colors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: hasFilter ? context.colors.primary : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: hasFilter
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacing2xs),
            Text(
              viewModel.filterParticipant?.nickname ?? 'Filter by Participant',
              style: AppTheme.bodySmall.copyWith(
                color: hasFilter
                    ? context.colors.primary
                    : context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacing2xs),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: hasFilter
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        if (hasFilter)
          const PopupMenuItem<Object?>(
            value: 'clear',
            child: Text('Clear filter'),
          ),
        ...viewModel.allParticipants.map((participant) {
          return PopupMenuItem<Object?>(
            value: participant,
            child: Text(
              participant.nickname ??
                  '${participant.firstName} ${participant.lastName}',
            ),
          );
        }),
      ],
      onSelected: (value) {
        if (value == 'clear') {
          viewModel.setFilterParticipant(null);
        } else if (value is models.Participant) {
          viewModel.setFilterParticipant(value);
        }
      },
    );
  }

  Widget _buildColorFilter(BuildContext context, BudgetingViewModel viewModel) {
    final categoryColors =
        viewModel.categories.map((c) => c.color).toSet().toList();

    final hasFilter = viewModel.filterColor != null;

    if (categoryColors.isEmpty) {
      return _buildFilterChip(
        context,
        label: 'Filter by Color',
        icon: Icons.palette,
        isActive: false,
        onTap: () {},
      );
    }

    return PopupMenuButton<Object?>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: hasFilter
              ? context.colors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: hasFilter ? context.colors.primary : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasFilter)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: viewModel.filterColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              )
            else
              Icon(
                Icons.palette,
                size: 16,
                color: context.colors.textSecondary,
              ),
            const SizedBox(width: AppTheme.spacing2xs),
            Text(
              'Filter by Color',
              style: AppTheme.bodySmall.copyWith(
                color: hasFilter
                    ? context.colors.primary
                    : context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacing2xs),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: hasFilter
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        if (hasFilter)
          const PopupMenuItem<Object?>(
            value: 'clear',
            child: Text('Clear filter'),
          ),
        ...categoryColors.map((color) {
          return PopupMenuItem<Object?>(
            value: color,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.border, width: 1),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(ColorPalette.getName(color)),
              ],
            ),
          );
        }),
      ],
      onSelected: (value) {
        if (value == 'clear') {
          viewModel.setFilterColor(null);
        } else if (value is Color) {
          viewModel.setFilterColor(value);
        }
      },
    );
  }
}
