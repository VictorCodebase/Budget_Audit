import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/client_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart' as models;
import '../budgeting_viewmodel.dart';
import 'participant_avatar.dart';
import 'inline_editable_text.dart';

class AccountRow extends StatefulWidget {
  final String categoryId;
  final AccountData account;
  final bool isLast;

  const AccountRow({
    Key? key,
    required this.categoryId,
    required this.account,
    this.isLast = false,
  }) : super(key: key);

  @override
  State<AccountRow> createState() => _AccountRowState();
}

class _AccountRowState extends State<AccountRow> {
  late FocusNode _budgetFocusNode;
  late FocusNode _participantFocusNode;
  late TextEditingController _participantController;

  @override
  void initState() {
    super.initState();
    _budgetFocusNode = FocusNode();
    _participantFocusNode = FocusNode();

    String initialText = '';
    if (widget.account.participants.isNotEmpty) {
      final p = widget.account.participants.first;
      initialText = p.nickname ?? '${p.firstName} ${p.lastName}';
    }
    _participantController = TextEditingController(text: initialText);
  }

  @override
  void didUpdateWidget(AccountRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.account.participants != oldWidget.account.participants) {
      String newText = '';
      if (widget.account.participants.isNotEmpty) {
        final p = widget.account.participants.first;
        newText = p.nickname ?? '${p.firstName} ${p.lastName}';
      }
      if (_participantController.text != newText) {
        _participantController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _budgetFocusNode.dispose();
    _participantFocusNode.dispose();
    _participantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BudgetingViewModel>();
    final isNew = viewModel.newlyAddedAccountId == widget.account.id;

    if (isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.clearNewlyAddedIds();
      });
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: widget.account.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: widget.account.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.account.validationError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: context.colors.error, size: 14),
                  const SizedBox(width: AppTheme.spacing2xs),
                  Expanded(
                    child: Text(
                      widget.account.validationError!,
                      style: AppTheme.caption
                          .copyWith(color: context.colors.error),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Name:',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(height: 4),
                    InlineEditableText(
                      text: widget.account.name,
                      isNew: isNew,
                      nextFocusNode: _budgetFocusNode,
                      onSubmitted: (value) {
                        viewModel.updateAccountName(
                          widget.categoryId,
                          widget.account.id,
                          value,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),

              // Account Budget
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Budget:',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(height: 4),
                    InlineEditableText(
                      text: widget.account.budgetAmount.toStringAsFixed(2),
                      focusNode: _budgetFocusNode,
                      nextFocusNode: _participantFocusNode,
                      selectAllOnFocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      prefixText: '\$',
                      onSubmitted: (value) {
                        final amount = double.tryParse(value);
                        if (amount != null && amount >= 0) {
                          viewModel.updateAccountBudget(
                            widget.categoryId,
                            widget.account.id,
                            amount,
                          );
                        }
                      },
                    ),
                  ],
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
                    const Text(
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
                  color: context.colors.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => viewModel.deleteAccount(
                      widget.categoryId, widget.account.id),
                  tooltip: 'Delete account',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantSelector(
      BuildContext context, BudgetingViewModel viewModel) {
    return RawAutocomplete<models.Participant>(
      focusNode: _participantFocusNode,
      textEditingController: _participantController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return viewModel.allParticipants;
        }
        return viewModel.allParticipants.where((models.Participant option) {
          final name =
              option.nickname ?? '${option.firstName} ${option.lastName}';
          return name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (models.Participant option) =>
          option.nickname ?? '${option.firstName} ${option.lastName}',
      onSelected: (models.Participant selection) {
        viewModel.updateAccountParticipants(
          widget.categoryId,
          widget.account.id,
          [selection],
        );
        _handleParticipantSubmit(context, viewModel, selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return InlineEditableText(
          text: widget.account.participants.isNotEmpty
              ? (widget.account.participants.first.nickname ??
                  '${widget.account.participants.first.firstName} ${widget.account.participants.first.lastName}')
              : '',
          controller: textEditingController,
          focusNode: fieldFocusNode,
          hintText: 'Select...',
          onSubmitted: (value) {
            // Logic handled by Autocomplete, but if Enter pressed on specific value:
            if (value.isEmpty) {
              // Determine if we need to set null
              if (widget.account.participants.isNotEmpty) {
                viewModel.updateAccountParticipants(
                    widget.categoryId, widget.account.id, []);
              }
              _handleParticipantSubmit(context, viewModel, null);
            } else {
              // Try to match exact or first option?
              // RawAutocomplete usually handles Enter if option selected.
              // If no option selected but text exists, what to do?
              // User wants "closest match".
              // We can manually find closest match if not via onSelected
              final participants = viewModel.allParticipants;
              models.Participant? match;
              try {
                match = participants.firstWhere(
                  (p) =>
                      (p.nickname ?? p.firstName).toLowerCase() ==
                      value.toLowerCase(),
                  orElse: () => participants.firstWhere(
                      (p) => (p.nickname ?? p.firstName)
                          .toLowerCase()
                          .contains(value.toLowerCase()),
                      orElse: () => participants.first),
                );
              } catch (e) {
                // If list is empty or other error
                match = null;
              }

              if (match != null) {
                viewModel.updateAccountParticipants(
                    widget.categoryId, widget.account.id, [match]);
                _handleParticipantSubmit(context, viewModel, match);
              } else {
                _handleParticipantSubmit(context, viewModel, null);
              }
            }
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<models.Participant> onSelected,
          Iterable<models.Participant> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final models.Participant option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ParticipantAvatar(participant: option, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(option.nickname ?? option.firstName)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleParticipantSubmit(BuildContext context,
      BudgetingViewModel viewModel, models.Participant? selected) {
    if (widget.isLast) {
      viewModel.addAccount(widget.categoryId);
      // Focus will be handled by the new row's isNew logic
    } else {
      FocusScope.of(context).nextFocus();
    }
  }
}
