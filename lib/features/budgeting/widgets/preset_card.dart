import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/preset_models.dart';
import 'package:intl/intl.dart';

class PresetCard extends StatefulWidget {
  final BudgetPreset preset;
  final Function(BudgetPreset, String, int) onAdopt;

  const PresetCard({
    Key? key,
    required this.preset,
    required this.onAdopt,
  }) : super(key: key);

  @override
  State<PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<PresetCard> {
  late String _selectedPeriod;
  late double _calculatedTotal; // To store the locally calculated total
  int _customMonths = 1;

  final List<String> _periodOptions = [
    'Monthly',
    'Quarterly',
    'Semi-Annually',
    'Annually',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.preset.period;
    if (!_periodOptions.contains(_selectedPeriod) &&
        _selectedPeriod != 'Custom') {
      // If the preset has a weird period not in our standard list, just treat it as is or default to Monthly?
      // For now, let's trust the preset or default to Monthly if it's really weird.
      if (widget.preset.period.startsWith('Custom')) {
        _selectedPeriod = 'Monthly'; // Fallback
      }
    }
    _recalculateTotal();
  }

  void _recalculateTotal() {
    // Crude multiplier logic here or import service?
    // Since we don't have easy injection here without provider lookups,
    // let's do a simple calculation similar to the service.

    double multiplier = 1.0;

    int targetMonths = 1;
    switch (_selectedPeriod) {
      case 'Monthly':
        targetMonths = 1;
        break;
      case 'Quarterly':
        targetMonths = 3;
        break;
      case 'Semi-Annually':
        targetMonths = 6;
        break;
      case 'Annually':
        targetMonths = 12;
        break;
      default:
        targetMonths = 1;
    }

    int sourceMonths = 1;
    switch (widget.preset.period) {
      case 'Monthly':
        sourceMonths = 1;
        break;
      case 'Quarterly':
        sourceMonths = 3;
        break;
      case 'Semi-Annually':
        sourceMonths = 6;
        break;
      case 'Annually':
        sourceMonths = 12;
        break;
      default:
        sourceMonths = 1;
    }

    multiplier = targetMonths / sourceMonths;
    _calculatedTotal = widget.preset.calculatedTotal * multiplier;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: context.colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.preset.name,
                      style: AppTheme.h3,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      widget.preset.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => widget.onAdopt(
                    widget.preset, _selectedPeriod, _customMonths),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingSm,
                  ),
                ),
                child: const Text('Adopt'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Divider
          Container(
            height: 1,
            color: context.colors.border,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Info chips
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildInfoChip(
                context,
                icon: Icons.people_outline,
                label: widget.preset.targetAudience,
              ),
              _buildInfoChip(
                context,
                icon: Icons.category_outlined,
                label: '${widget.preset.totalCategories} categories',
              ),
              _buildInfoChip(
                context,
                icon: Icons.account_balance_wallet_outlined,
                label: '${widget.preset.totalAccounts} accounts',
              ),
              // Period Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: context.colors.border,
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isDense: true,
                    icon: Icon(Icons.arrow_drop_down,
                        size: 20, color: context.colors.textSecondary),
                    style: AppTheme.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                          _recalculateTotal();
                        });
                      }
                    },
                    items: _periodOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _buildInfoChip(
                context,
                icon: Icons.attach_money,
                label: currencyFormatter.format(_calculatedTotal),
                isHighlight: true,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Categories preview
          Text(
            'Categories Preview',
            style: AppTheme.bodySmall.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Wrap(
            spacing: AppTheme.spacingXs,
            runSpacing: AppTheme.spacingXs,
            children: widget.preset.categories.take(8).map<Widget>((category) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  category.name,
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              );
            }).toList()
              ..add(
                widget.preset.categories.length > 8
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: AppTheme.spacingXs,
                        ),
                        child: Text(
                          '+${widget.preset.categories.length - 8} more',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.colors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      height: 36, // Fixed height to match dropdown
      decoration: BoxDecoration(
        color: isHighlight
            ? context.colors.secondary.withOpacity(0.1)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: isHighlight ? context.colors.secondary : context.colors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlight
                ? context.colors.secondary
                : context.colors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isHighlight
                  ? context.colors.secondary
                  : context.colors.textSecondary,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
