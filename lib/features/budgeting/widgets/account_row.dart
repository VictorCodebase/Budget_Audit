import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/client_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart' as models;
import '../budgeting_viewmodel.dart';
import 'participant_avatar.dart';

class AccountRow extends StatelessWidget {
  final String categoryId;
  final AccountData account;

  const AccountRow({
    Key? key,
    required this.categoryId,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BudgetingViewModel>();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: account.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: account.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (account.validationError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 14),
                  const SizedBox(width: AppTheme.spacing2xs),
                  Expanded(
                    child: Text(
                      account.validationError!,
                      style: AppTheme.caption.copyWith(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Name
              Expanded(
                flex: 2,
                child: _buildField(
                  context,
                  label: 'Account Name:',
                  value: account.name,
                  onTap: () => _showNameEditor(context, viewModel),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),

              // Account Budget
              Expanded(
                flex: 1,
                child: _buildField(
                  context,
                  label: 'Account Budget:',
                  value: '\$${account.budgetAmount.toStringAsFixed(2)}',
                  onTap: () => _showBudgetEditor(context, viewModel),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),

              // Associate participant
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Associate participant',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(height: 4),
                    _buildParticipantSelector(context, viewModel),
                  ],
                ),
              ),

              // Delete button
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: AppTheme.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => viewModel.deleteAccount(categoryId, account.id),
                  tooltip: 'Delete account',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      BuildContext context, {
        required String label,
        required String value,
        required VoidCallback onTap,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.caption,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXs,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Text(
              value,
              style: AppTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantSelector(
      BuildContext context,
      BudgetingViewModel viewModel,
      ) {
    if (account.participants.isEmpty) {
      return InkWell(
        onTap: () => _showParticipantPicker(context, viewModel),
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXs,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'None',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showParticipantPicker(context, viewModel),
      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXs,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...account.participants.map((participant) {
              return ParticipantAvatar(
                participant: participant,
                size: 20,
              );
            }),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: const Icon(Icons.add, size: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showNameEditor(BuildContext context, BudgetingViewModel viewModel) {
    final controller = TextEditingController(text: account.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Account Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              hintText: 'Enter account name',
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                viewModel.updateAccountName(
                  categoryId,
                  account.id,
                  value.trim(),
                );
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  viewModel.updateAccountName(
                    categoryId,
                    account.id,
                    controller.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showBudgetEditor(BuildContext context, BudgetingViewModel viewModel) {
    final controller = TextEditingController(
      text: account.budgetAmount.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Budget Amount'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Budget Amount',
              hintText: 'Enter amount',
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            autofocus: true,
            onSubmitted: (value) {
              final amount = double.tryParse(value);
              if (amount != null && amount > 0) {
                viewModel.updateAccountBudget(categoryId, account.id, amount);
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  viewModel.updateAccountBudget(categoryId, account.id, amount);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showParticipantPicker(BuildContext context, BudgetingViewModel viewModel) {
    final selectedIds = account.participants.map((p) => p.participantId).toSet();
    final tempSelected = Set<int>.from(selectedIds);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Participants'),
              content: SizedBox(
                width: double.maxFinite,
                child: viewModel.allParticipants.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingLg),
                  child: Center(
                    child: Text('No participants available'),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: viewModel.allParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = viewModel.allParticipants[index];
                    final isSelected = tempSelected.contains(participant.participantId);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(participant.participantId);
                          } else {
                            tempSelected.remove(participant.participantId);
                          }
                        });
                      },
                      title: Row(
                        children: [
                          ParticipantAvatar(
                            participant: participant,
                            size: 32,
                            showTooltip: false,
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Expanded(
                            child: Text(
                              participant.nickname ??
                                  '${participant.firstName} ${participant.lastName}',
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final selected = viewModel.allParticipants
                        .where((p) => tempSelected.contains(p.participantId))
                        .toList();
                    viewModel.updateAccountParticipants(
                      categoryId,
                      account.id,
                      selected,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}