import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/features/settings/management_viewmodels/vendor_management_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Vendor management section showing vendor-account associations
class VendorSection extends StatefulWidget {
  const VendorSection({Key? key}) : super(key: key);

  @override
  State<VendorSection> createState() => _VendorSectionState();
}

class _VendorSectionState extends State<VendorSection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VendorManagementViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendor Management',
                    style: AppTheme.h2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2xs),
                  Text(
                    'Manage vendor-account associations',
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),

        // Search and Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search vendors or accounts...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // Vendor Filter Dropdown
            DropdownButton<int?>(
              value: viewModel.selectedVendorId,
              hint: const Text('All Vendors'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Vendors'),
                ),
                ...viewModel.vendors.map((vendor) {
                  return DropdownMenuItem<int?>(
                    value: vendor.vendorId,
                    child: Text(
                      vendor.vendorName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                viewModel.selectVendor(value);
              },
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),

        if (viewModel.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingXl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (viewModel.associations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Text(
                'No vendor associations found',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          )
        else
          _buildAssociationsList(context, viewModel),

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

  Widget _buildAssociationsList(
    BuildContext context,
    VendorManagementViewModel viewModel,
  ) {
    // Apply search filter
    final filteredAssociations = _searchQuery.isEmpty
        ? viewModel.filteredAssociations
        : viewModel.searchAssociations(_searchQuery);

    if (filteredAssociations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Text(
            'No associations match your search',
            style: AppTheme.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout
        if (constraints.maxWidth > 800) {
          return _buildAssociationsTable(
            context,
            viewModel,
            filteredAssociations,
          );
        } else {
          return _buildAssociationsCards(
            context,
            viewModel,
            filteredAssociations,
          );
        }
      },
    );
  }

  // Table layout for wide screens
  Widget _buildAssociationsTable(
    BuildContext context,
    VendorManagementViewModel viewModel,
    List<VendorAccountAssociation> associations,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.colors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Vendor',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Account',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'User',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Uses',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Last Used',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 60), // Space for delete button
              ],
            ),
          ),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: associations.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: context.colors.border,
            ),
            itemBuilder: (context, index) {
              final association = associations[index];
              return _buildAssociationRow(context, viewModel, association);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationRow(
    BuildContext context,
    VendorManagementViewModel viewModel,
    VendorAccountAssociation association,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              association.vendor.vendorName,
              style: AppTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              association.account.accountName,
              style: AppTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              association.participant.nickname ??
                  association.participant.firstName,
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              '${association.useCount}x',
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              DateFormat('MMM d, yyyy').format(association.lastUsed),
              style: AppTheme.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: context.colors.error,
              size: 20,
            ),
            onPressed: () =>
                _confirmDeleteAssociation(context, viewModel, association),
            tooltip: 'Delete association',
          ),
        ],
      ),
    );
  }

  // Card layout for narrow screens
  Widget _buildAssociationsCards(
    BuildContext context,
    VendorManagementViewModel viewModel,
    List<VendorAccountAssociation> associations,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: associations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppTheme.spacingSm),
      itemBuilder: (context, index) {
        final association = associations[index];
        return _buildAssociationCard(context, viewModel, association);
      },
    );
  }

  Widget _buildAssociationCard(
    BuildContext context,
    VendorManagementViewModel viewModel,
    VendorAccountAssociation association,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      association.vendor.vendorName,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2xs),
                    Text(
                      association.account.accountName,
                      style: AppTheme.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: context.colors.error,
                ),
                onPressed: () =>
                    _confirmDeleteAssociation(context, viewModel, association),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User',
                      style: AppTheme.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      association.participant.nickname ??
                          association.participant.firstName,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uses',
                      style: AppTheme.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      '${association.useCount}x',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Used',
                      style: AppTheme.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(association.lastUsed),
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAssociation(
    BuildContext context,
    VendorManagementViewModel viewModel,
    VendorAccountAssociation association,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Association'),
        content: Text(
          'Delete the association between "${association.vendor.vendorName}" '
          'and "${association.account.accountName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteAssociation(association);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Association deleted successfully'),
                    backgroundColor: context.colors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
