import 'package:flutter/material.dart';
import 'package:budget_audit/core/models/client_models.dart';

class EnhancedAccountSelector extends StatefulWidget {
  final List<CategoryData> categories;
  final String? selectedAccountId;
  final ValueChanged<AccountData> onAccountSelected;
  final int? vendorId;
  final Function(int, int)? onDeleteRecommendation;

  const EnhancedAccountSelector({
    super.key,
    required this.categories,
    required this.selectedAccountId,
    required this.onAccountSelected,
    this.vendorId,
    this.onDeleteRecommendation,
  });

  @override
  State<EnhancedAccountSelector> createState() =>
      _EnhancedAccountSelectorState();
}

class _EnhancedAccountSelectorState extends State<EnhancedAccountSelector> {
  late List<_AccountOption> _allAccounts;

  @override
  void initState() {
    super.initState();
    _buildAccountOptions();
  }

  @override
  void didUpdateWidget(EnhancedAccountSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _buildAccountOptions();
    }
  }

  void _buildAccountOptions() {
    _allAccounts = widget.categories.expand((category) {
      return category.accounts.map((account) {
        return _AccountOption(
          account: account,
          categoryName: category.name,
          categoryColor: category.color,
        );
      });
    }).toList();

    _allAccounts.sort((a, b) => '${a.categoryName} - ${a.account.name}'
        .compareTo('${b.categoryName} - ${b.account.name}'));
  }

  String _getDisplayStringForOption(_AccountOption option) =>
      option.account.name;

  String _getInitialValue() {
    if (widget.selectedAccountId != null) {
      final match = _allAccounts
          .where((a) => a.account.id == widget.selectedAccountId)
          .firstOrNull;
      return match?.account.name ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Key is crucial to force rebuild when selection changes from outside
      return Autocomplete<_AccountOption>(
        key: ValueKey(widget.selectedAccountId),
        displayStringForOption: _getDisplayStringForOption,
        initialValue: TextEditingValue(text: _getInitialValue()),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<_AccountOption>.empty();
          }
          return _allAccounts.where((option) {
            final searchString =
                '${option.categoryName} - ${option.account.name}'.toLowerCase();
            return searchString.contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (option) {
          widget.onAccountSelected(option.account);
        },
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Select Account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            style: const TextStyle(fontSize: 13),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: constraints.maxWidth,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: option.categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${option.categoryName} - ',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: option.account.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
    });
  }
}

class _AccountOption {
  final AccountData account;
  final String categoryName;
  final Color categoryColor;

  _AccountOption({
    required this.account,
    required this.categoryName,
    required this.categoryColor,
  });
}
