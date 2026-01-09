import 'package:budget_audit/core/services/parser/parser_factory.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Import uuid
import '../../core/context.dart';
import '../../core/models/models.dart' as models;
import '../../core/models/client_models.dart' as clientModels;
import '../../core/services/budget_service.dart';
import '../../core/services/participant_service.dart';
import '../../core/utils/hex_to_color.dart';
import '../../core/utils/color_palette.dart';

enum FilterType { name, totalBudget, participant, color }

enum SortOrder { asc, desc }

class BudgetingViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final ParticipantService _participantService;
  final AppContext _appContext;

  BudgetingViewModel(
    this._budgetService,
    this._participantService,
    this._appContext,
  );

  List<clientModels.CategoryData> _categories = [];
  List<models.Participant> _allParticipants = [];
  List<models.Template> _templates = [];

  String _searchQuery = '';
  FilterType?
      _currentFilter; // Nullable to allow "no filter" (user selected order)
  SortOrder _sortOrder = SortOrder.asc;
  models.Participant? _filterParticipant;
  Color? _filterColor;

  bool _isLoading = false;
  String? _errorMessage;

  // Expose services for the view
  AccountService get accountService => _budgetService.accountService;

  ParticipantService get participantService => _participantService;

  List<clientModels.CategoryData> get categories =>
      _filteredAndSortedCategories();

  List<models.Participant> get allParticipants => _allParticipants;

  List<models.Template> get templates => _templates;

  String get searchQuery => _searchQuery;

  FilterType? get currentFilter => _currentFilter;

  SortOrder get sortOrder => _sortOrder;

  models.Participant? get filterParticipant => _filterParticipant;

  Color? get filterColor => _filterColor;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? _newlyAddedCategoryId;
  String? _newlyAddedAccountId;

  String? get newlyAddedCategoryId => _newlyAddedCategoryId;
  String? get newlyAddedAccountId => _newlyAddedAccountId;

  // Budget Period
  final List<String> periodOptions = [
    'Monthly',
    'Quarterly',
    'Semi-Annually',
    'Annually',
    'Custom'
  ];
  String _selectedPeriod = 'Monthly';
  int _customPeriodMonths = 1;

  String get selectedPeriod => _selectedPeriod;
  int get customPeriodMonths => _customPeriodMonths;
  List<String> get availablePeriods => periodOptions;

  void setPeriod(String period) {
    if (periodOptions.contains(period)) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  void setCustomPeriodMonths(int months) {
    if (months > 0 && months <= 60) {
      _customPeriodMonths = months;
      notifyListeners();
    }
  }

  void clearNewlyAddedIds() {
    _newlyAddedCategoryId = null;
    _newlyAddedAccountId = null;
    // No notifyListeners needed here as this is usually called after build or during focus change
  }

  bool get hasUnsavedChanges => _categories.isNotEmpty;

  bool get canSave {
    if (_categories.isEmpty) return false;

    // Check for at least one category with at least one account
    bool hasValidCategory = _categories.any((cat) => cat.accounts.isNotEmpty);
    if (!hasValidCategory) return false;

    // Check all categories have unique, non-empty names
    final names = _categories.map((c) => c.name.trim().toUpperCase()).toList();
    if (names.any((name) => name.isEmpty || name == 'CATEGORY NAME')) {
      return false;
    }
    if (names.length != names.toSet().length) return false;

    // Check all accounts have names and positive budgets
    for (var category in _categories) {
      for (var account in category.accounts) {
        if (account.name.trim().isEmpty) return false;
        if (account.budgetAmount <= 0) return false;
      }
    }

    return true;
  }

  String? get saveValidationMessage {
    if (_categories.isEmpty) {
      return 'Please add at least one category with an account';
    }

    bool hasValidCategory = _categories.any((cat) => cat.accounts.isNotEmpty);
    if (!hasValidCategory) {
      return 'Each category must have at least one account';
    }

    // Check for duplicate or invalid category names
    final names = _categories.map((c) => c.name.trim().toUpperCase()).toList();
    if (names.any((name) => name.isEmpty || name == 'CATEGORY NAME')) {
      return 'All categories must have valid names';
    }
    if (names.length != names.toSet().length) {
      return 'Category names must be unique';
    }

    // Check account validation
    for (var category in _categories) {
      for (var account in category.accounts) {
        if (account.name.trim().isEmpty) {
          return 'All accounts must have names';
        }
        if (account.budgetAmount <= 0) {
          return 'All accounts must have positive budget amounts';
        }
      }
    }

    return null;
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allParticipants = await _participantService.getAllParticipants();
      _templates = await _budgetService.templateService.getAllTemplates();

      final activeTemplate = _appContext.currentTemplate;
      if (activeTemplate != null) {
        // If there's an active template, load its data for editing.
        debugPrint("Active template found: ${activeTemplate.templateName}");
        await _loadTemplateForEditing(activeTemplate);
      } else {
        // Clear categories if no active template
        _categories = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();

      // Listen for global context changes (e.g. template switching)
      _appContext.addListener(_onAppContextChange);
    }
  }

  @override
  void dispose() {
    _appContext.removeListener(_onAppContextChange);
    super.dispose();
  }

  void _onAppContextChange() {
    final activeTemplate = _appContext.currentTemplate;

    // If we have no categories yet (first load) or if the template ID changed
    // we should reload. A simple check is if we have an active template but e.g.
    // our internal state doesn't match, or just purely reload if the template object changed.

    // Simplest approach: compare IDs if possible.
    // Since _loadTemplateForEditing handles setting internal state, we can just call it
    // if we detect a switch.

    // However, we want to avoid reloading if we are currently editing the SAME template
    // and just updated a small property via this view model (which might trigger app context update).
    // But AppContext is usually updated via adopt or manual switch.

    if (activeTemplate != null) {
      // Check if we are already editing this template
      // We don't have a simple _currentTemplateId field, but we can verify against known data

      // NOTE: For now, we will reload if the current loaded data seems 'stale'
      // or simply rely on the user to initiate the switch via the UI which calls initialize.
      // The user requested: "ensure that if there is an active budget in context, the budget period reflects the budget's period"

      // Let's check specifically for period mismatch or if we should just re-run the parse logic

      final periodStr = activeTemplate.period;
      // Re-parse period logic to ensure UI stays in sync
      if (periodStr.startsWith('Custom:')) {
        final parts = periodStr.split(' ');
        if (parts.length >= 2) {
          final months = int.tryParse(parts[1]) ?? 1;
          if (_selectedPeriod != 'Custom' || _customPeriodMonths != months) {
            _selectedPeriod = 'Custom';
            _customPeriodMonths = months;
            notifyListeners();
          }
        }
      } else {
        if (_selectedPeriod != periodStr) {
          _selectedPeriod = periodStr;
          notifyListeners();
        }
      }
    }
  }

  Future<void> _loadTemplateForEditing(models.Template template) async {
    try {
      // 1. Load all categories for this template
      debugPrint("Loading categories for template: ${template.templateName}");
      final categoriesFromDb = await _budgetService.categoryService
          .getCategoriesForTemplate(template.templateId);
      debugPrint("Categories from db (0th): ${categoriesFromDb[0]}");

      // 2. Load accounts for each category and convert to local CategoryData
      final List<clientModels.CategoryData> loadedCategories = [];

      for (var category in categoriesFromDb) {
        final accountsFromDb = await _budgetService.accountService
            .getAccountsForCategory(template.templateId, category.categoryId);
        // Convert database accounts to local AccountData
        final List<clientModels.AccountData> accountDataList = [];
        for (var account in accountsFromDb) {
          final participant = account.responsibleParticipantId != null
              ? await _participantService
                  .getParticipant(account.responsibleParticipantId!)
              : null; // Check for null

          accountDataList.add(clientModels.AccountData(
            // Use the real database ID for editing
            id: account.accountId.toString(),
            name: account.accountName,
            budgetAmount: account.budgetAmount,
            participants: participant != null ? [participant] : [],
            color: hexToColor(account.colorHex),
          ));
        }

        loadedCategories.add(clientModels.CategoryData(
          // Use the real database ID for editing
          id: category.categoryId.toString(),
          name: category.categoryName,
          color: hexToColor(category.colorHex),
          accounts: accountDataList,
        ));
      }
      debugPrint("Loaded categories (1st): ${loadedCategories[0]}");
      // 3. Set the loaded categories as the current working state
      _categories = loadedCategories;

      // 4. Parse period
      final periodStr = template.period; // "Monthly" or "Custom: 5 Months"
      if (periodStr.startsWith('Custom:')) {
        _selectedPeriod = 'Custom';
        try {
          final parts = periodStr.split(' '); // "Custom:", "5", "Months"
          if (parts.length >= 2) {
            _customPeriodMonths = int.tryParse(parts[1]) ?? 1;
          }
        } catch (e) {
          _customPeriodMonths = 1;
        }
      } else {
        if (periodOptions.contains(periodStr)) {
          _selectedPeriod = periodStr;
        } else {
          _selectedPeriod = 'Monthly'; // Fallback
        }
      }

      // Note: We don't call notifyListeners() here because the calling method will do it.
    } catch (e) {
      _errorMessage = 'Failed to load template data: $e';
    }
  }

  void addCategory() {
    clearFilters(); // Clear filters so user sees the new category
    final newCategory = clientModels.CategoryData(
      id: const Uuid().v4(),
      name: 'CATEGORY NAME',
      color: _generateRandomColor(),
    );
    _categories.add(newCategory);
    _newlyAddedCategoryId = newCategory.id;
    _expandedCategoryId = newCategory.id;
    notifyListeners();
  }

  void updateCategoryName(String categoryId, String newName) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(name: newName);
      _validateCategories();
      notifyListeners();
    }
  }

  void updateCategoryColor(String categoryId, Color newColor) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      final category = _categories[index];
      _categories[index] = category.copyWith(color: newColor);

      // Update all account colors to lighter variations
      final updatedAccounts = category.accounts.map((account) {
        return account.copyWith(color: _generateLighterShade(newColor));
      }).toList();

      _categories[index] =
          _categories[index].copyWith(accounts: updatedAccounts);
      notifyListeners();
    }
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  void addAccount(String categoryId) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      final category = _categories[index];
      final newAccount = clientModels.AccountData(
        id: const Uuid().v4(),
        name: 'Account name',
        budgetAmount: 0.0,
        color: _generateLighterShade(category.color),
      );

      final updatedAccounts = [...category.accounts, newAccount];
      _categories[index] = category.copyWith(accounts: updatedAccounts);
      _newlyAddedAccountId = newAccount.id;
      notifyListeners();
    }
  }

  void updateAccountName(String categoryId, String accountId, String newName) {
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex != -1) {
      final category = _categories[catIndex];
      final accIndex = category.accounts.indexWhere((a) => a.id == accountId);

      if (accIndex != -1) {
        final updatedAccounts = [...category.accounts];
        updatedAccounts[accIndex] =
            updatedAccounts[accIndex].copyWith(name: newName);
        _categories[catIndex] = category.copyWith(accounts: updatedAccounts);
        notifyListeners();
      }
    }
  }

  void updateAccountBudget(String categoryId, String accountId, double amount) {
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex != -1) {
      final category = _categories[catIndex];
      final accIndex = category.accounts.indexWhere((a) => a.id == accountId);

      if (accIndex != -1) {
        final updatedAccounts = [...category.accounts];
        updatedAccounts[accIndex] =
            updatedAccounts[accIndex].copyWith(budgetAmount: amount);
        _categories[catIndex] = category.copyWith(accounts: updatedAccounts);
        notifyListeners();
      }
    }
  }

  void updateAccountParticipants(
    String categoryId,
    String accountId,
    List<models.Participant> participants,
  ) {
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex != -1) {
      final category = _categories[catIndex];
      final accIndex = category.accounts.indexWhere((a) => a.id == accountId);

      if (accIndex != -1) {
        final updatedAccounts = [...category.accounts];
        updatedAccounts[accIndex] = updatedAccounts[accIndex].copyWith(
          participants: participants,
        );
        _categories[catIndex] = category.copyWith(accounts: updatedAccounts);
        notifyListeners();
      }
    }
  }

  void deleteAccount(String categoryId, String accountId) {
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex != -1) {
      final category = _categories[catIndex];
      final updatedAccounts =
          category.accounts.where((a) => a.id != accountId).toList();
      _categories[catIndex] = category.copyWith(accounts: updatedAccounts);
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      // Reset to name filter when searching
      _currentFilter = FilterType.name;
    }
    notifyListeners();
  }

  void setFilter(FilterType filter, {SortOrder? order}) {
    if (_currentFilter == filter) {
      // Tri-state toggle: Asc -> Desc -> Off
      if (_sortOrder == SortOrder.asc) {
        _sortOrder = SortOrder.desc;
      } else {
        _currentFilter = null;
        _sortOrder = SortOrder.asc; // Reset to default
      }
    } else {
      _currentFilter = filter;
      _sortOrder = order ?? SortOrder.asc;
    }
    notifyListeners();
  }

  void setFilterParticipant(models.Participant? participant) {
    _filterParticipant = participant;
    notifyListeners();
  }

  void setFilterColor(Color? color) {
    _filterColor = color;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _currentFilter = null;
    _sortOrder = SortOrder.asc;
    _filterParticipant = null;
    _filterColor = null;
    notifyListeners();
  }

  Future<bool> saveTemplate({
    required String templateName,
    required int creatorParticipantId,
  }) async {
    if (!canSave) {
      _errorMessage = saveValidationMessage;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create the template
      final periodString = _selectedPeriod == 'Custom'
          ? 'Custom: $_customPeriodMonths Months'
          : _selectedPeriod;

      final newTemplate = clientModels.Template(
        templateName: templateName,
        creatorParticipantId: creatorParticipantId,
        dateCreated: DateTime.now(),
        period: periodString,
      );

      final templateId =
          await _budgetService.templateService.createTemplate(newTemplate);
      if (templateId == null) {
        throw Exception('Failed to create template');
      }

      // 2. Create categories and accounts
      for (var category in _categories) {
        // Create category with templateId
        final newCategory = clientModels.Category(
          categoryName: category.name,
          colorHex: _colorToHex(category.color),
          templateId: templateId,
        );

        final categoryId =
            await _budgetService.categoryService.createCategory(newCategory);
        if (categoryId == null) {
          throw Exception('Failed to create category: ${category.name}');
        }

        // Create accounts for this category
        for (var account in category.accounts) {
          final newAccount = clientModels.Account(
            categoryId: categoryId,
            templateId: templateId,
            accountName: account.name,
            colorHex: _colorToHex(account.color),
            budgetAmount: account.budgetAmount,
            expenditureTotal: 0.0,
            responsibleParticipantId: account.participants.isNotEmpty
                ? account.participants.first.participantId
                : null, // Don't default to creator
            dateCreated: DateTime.now(),
          );

          await _budgetService.accountService.createAccount(newAccount);
        }
      }

      // 3. Load the created template and set as current
      final createdTemplate =
          await _budgetService.templateService.getTemplate(templateId);
      if (createdTemplate != null) {
        await setNewTemplateAsCurrent(createdTemplate);
      } else {
        // If for some reason it fails to fetch, clear the state
        _categories.clear();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save template: $e';
      print("ERROR while saving template: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setNewTemplateAsCurrent(models.Template template) async {
    await _appContext.setCurrentTemplate(template);

    _templates.removeWhere((t) => t.templateId == template.templateId);
    _templates.add(template);

    //_categories.clear();
    await _loadTemplateForEditing(template);

    // Notify listeners to rebuild the UI with the cleared state
    notifyListeners();
  }

  void startNewTemplate() {
    _categories = [];
    _selectedPeriod = 'Monthly';
    _customPeriodMonths = 1;
    _appContext.clearCurrentTemplate();
    notifyListeners();
  }

  Future<bool> updateTemplate({
    required int templateId,
    required String templateName,
  }) async {
    if (!canSave) {
      _errorMessage = saveValidationMessage;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 0. Update the template record (name and period)
      // Construct period string
      final periodString = _selectedPeriod == 'Custom'
          ? 'Custom: $_customPeriodMonths Months'
          : _selectedPeriod;

      // We create a temporary object to pass data. ensure required fields are present even if unused by the specific update query.
      final templateUpdateData = models.Template(
        templateId: templateId,
        templateName: templateName,
        period: periodString,
        creatorParticipantId: 0, // Unused by updateTemplate
        dateCreated: DateTime.now(), // Unused by updateTemplate
      );

      final success = await _budgetService.templateService
          .updateTemplate(templateUpdateData);

      if (!success) {
        throw Exception('Failed to update template details');
      }

      // 1. Identify categories to delete
      final existingCategories = await _budgetService.categoryService
          .getCategoriesForTemplate(templateId);
      final currentCategoryIds = _categories
          .map((c) => int.tryParse(c.id))
          .where((id) => id != null)
          .toSet();

      final categoriesToDelete = existingCategories
          .where((c) => !currentCategoryIds.contains(c.categoryId))
          .toList();

      for (var category in categoriesToDelete) {
        await _budgetService.categoryService
            .deleteCategory(category.categoryId);
      }

      // 2. Update or Create categories
      for (var categoryData in _categories) {
        final categoryIdInt = int.tryParse(categoryData.id);

        // Determine if we are updating an existing category or creating a new one
        if (categoryIdInt != null &&
            existingCategories.any((c) => c.categoryId == categoryIdInt)) {
          // --- UPDATE Existing Category ---
          final updatedCategory = models.Category(
            categoryId: categoryIdInt,
            templateId: templateId,
            categoryName: categoryData.name,
            colorHex: _colorToHex(categoryData.color),
          );

          await _budgetService.categoryService.updateCategory(updatedCategory);

          // Handle Accounts for this Category
          final existingAccounts = await _budgetService.accountService
              .getAccountsForCategory(templateId, categoryIdInt);

          final currentAccountIds = categoryData.accounts
              .map((a) => int.tryParse(a.id))
              .where((id) => id != null)
              .toSet();

          // Delete removed accounts
          final accountsToDelete = existingAccounts
              .where((a) => !currentAccountIds.contains(a.accountId))
              .toList();

          for (var account in accountsToDelete) {
            await _budgetService.accountService
                .deleteAccount(account.accountId);
          }

          // Update or Create accounts
          for (var accountData in categoryData.accounts) {
            final accountIdInt = int.tryParse(accountData.id);
            if (accountIdInt != null &&
                existingAccounts.any((a) => a.accountId == accountIdInt)) {
              // Update existing account
              final existingAccount = existingAccounts
                  .firstWhere((a) => a.accountId == accountIdInt);

              final modifiedAccount = models.Account(
                accountId: accountIdInt,
                categoryId: categoryIdInt,
                templateId: templateId,
                accountName: accountData.name,
                colorHex: _colorToHex(accountData.color),
                budgetAmount: accountData.budgetAmount,
                expenditureTotal: existingAccount.expenditureTotal, // Preserve
                responsibleParticipantId: accountData.participants.isNotEmpty
                    ? accountData.participants.first.participantId
                    : null,
                dateCreated: existingAccount.dateCreated, // Preserve
              );
              await _budgetService.accountService
                  .modifyAccount(modifiedAccount);
            } else {
              // Create new account in existing category
              final newAccount = clientModels.Account(
                categoryId: categoryIdInt,
                templateId: templateId,
                accountName: accountData.name,
                colorHex: _colorToHex(accountData.color),
                budgetAmount: accountData.budgetAmount,
                expenditureTotal: 0.0,
                responsibleParticipantId: accountData.participants.isNotEmpty
                    ? accountData.participants.first.participantId
                    : null,
                dateCreated: DateTime.now(),
              );
              await _budgetService.accountService.createAccount(newAccount);
            }
          }
        } else {
          // --- CREATE New Category ---
          final newCategory = clientModels.Category(
            categoryName: categoryData.name,
            colorHex: _colorToHex(categoryData.color),
            templateId: templateId,
          );

          final newCategoryId =
              await _budgetService.categoryService.createCategory(newCategory);

          if (newCategoryId == null) {
            throw Exception('Failed to create category: ${categoryData.name}');
          }

          // Create accounts for new category
          for (var accountData in categoryData.accounts) {
            final newAccount = clientModels.Account(
              categoryId: newCategoryId,
              templateId: templateId,
              accountName: accountData.name,
              colorHex: _colorToHex(accountData.color),
              budgetAmount: accountData.budgetAmount,
              expenditureTotal: 0.0,
              responsibleParticipantId: accountData.participants.isNotEmpty
                  ? accountData.participants.first.participantId
                  : null,
              dateCreated: DateTime.now(),
            );

            await _budgetService.accountService.createAccount(newAccount);
          }
        }
      }

      _isLoading = false;

      final updatedTemplate =
          await _budgetService.templateService.getTemplate(templateId);
      if (updatedTemplate != null) {
        await _loadTemplateForEditing(updatedTemplate);

        // Update global context if this is the active template
        if (_appContext.currentTemplate?.templateId == templateId) {
          await _appContext.setCurrentTemplate(updatedTemplate);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update template: $e';
      print("ERROR while updating template: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> adoptTemplate(
      models.Template template, int participantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      //_categories.clear();
      await _loadTemplateForEditing(template);
      await _appContext.setCurrentTemplate(template);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to adopt template: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(int templateId) async {
    try {
      final success =
          await _budgetService.templateService.deleteTemplate(templateId);
      if (success) {
        _templates.removeWhere((t) => t.templateId == templateId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to delete template: $e';
      notifyListeners();
    }
  }

  // Private helper methods

  List<clientModels.CategoryData> _filteredAndSortedCategories() {
    var filtered = _categories.where((category) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = category.name.toLowerCase().contains(query);
        final accountMatch = category.accounts.any(
          (a) => a.name.toLowerCase().contains(query),
        );
        if (!nameMatch && !accountMatch) return false;
      }

      // Participant filter
      if (_filterParticipant != null) {
        final hasParticipant = category.accounts.any(
          (a) => a.participants
              .any((p) => p.participantId == _filterParticipant!.participantId),
        );
        if (!hasParticipant) return false;
      }

      // Color filter
      if (_filterColor != null) {
        if (category.color.value != _filterColor!.value) return false;
      }

      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      // Always put the newly added category at the end if we are sorting by name
      // and the name is still the default "CATEGORY NAME"
      if (_currentFilter == FilterType.name) {
        final isANew = a.id == _newlyAddedCategoryId;
        final isBNew = b.id == _newlyAddedCategoryId;

        if (isANew && !isBNew) return 1;
        if (!isANew && isBNew) return -1;
      } else if (_currentFilter == null) {
        // No sort: preserve order (or explicit order if implemented)
        // Since _categories is the source list and we return a new list,
        // using 0 here effectively implies "original list order" if sort is stable.
        // But Dart's sort is stable, so 0 works to keep relative order if used carefully.
        // Actually, if filter is null, we can return the list directly, but we might have filtered items.
        // Since we did `where` query, we have a new list.
        // Returning 0 keeps them in relative order.
        return 0;
      }

      int comparison;
      switch (_currentFilter) {
        case FilterType.name:
          comparison = a.name.compareTo(b.name);
          break;
        case FilterType.totalBudget:
          comparison = a.totalBudget.compareTo(b.totalBudget);
          break;
        case FilterType.participant:
          comparison =
              a.allParticipants.length.compareTo(b.allParticipants.length);
          break;
        case FilterType.color:
          comparison = a.color.value.compareTo(b.color.value);
          break;
        case null:
          return 0;
      }

      return _sortOrder == SortOrder.asc ? comparison : -comparison;
    });

    return filtered;
  }

  String? _expandedCategoryId;
  String? get expandedCategoryId => _expandedCategoryId;

  void setExpandedCategory(String? categoryId) {
    // If clicking the already expanded one, collapse it (pass null or handle in UI)
    // But usually we want to toggle. Here we just set it.
    if (_expandedCategoryId == categoryId) {
      _expandedCategoryId = null;
    } else {
      _expandedCategoryId = categoryId;
    }
    notifyListeners();
  }

  Color _generateRandomColor() {
    return ColorPalette.getRandom();
  }

  Color _generateLighterShade(Color baseColor) {
    final hslColor = HSLColor.fromColor(baseColor);
    final lighterHsl = hslColor.withLightness(
      (hslColor.lightness + 0.15).clamp(0.0, 1.0),
    );
    return lighterHsl.toColor();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _validateCategories() {
    final names = <String, int>{};

    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      final normalizedName = category.name.trim().toUpperCase();

      String? error;

      if (normalizedName.isEmpty || normalizedName == 'CATEGORY NAME') {
        error = 'Please provide a valid category name';
      } else if (names.containsKey(normalizedName)) {
        error = 'Category name must be unique';
      }

      names[normalizedName] = i;
      _categories[i] = category.copyWith(validationError: error);
    }
  }
}
