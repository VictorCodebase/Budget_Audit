import 'package:budget_audit/core/services/parser/parser_factory.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/context.dart';
import '../../core/models/models.dart' as models;
import '../../core/models/client_models.dart' as clientModels;
import '../../core/services/budget_service.dart';
import '../../core/services/participant_service.dart';
import '../../core/utils/hex_to_color.dart';
import '../../core/utils/color_palette.dart';
import '../../core/models/preset_models.dart';
import '../../core/services/preset_service.dart';

enum FilterType { name, totalBudget, participant, color }

enum SortOrder { asc, desc }

class BudgetingViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final ParticipantService _participantService;
  final AppContext _appContext;
  final PresetService _presetService;

  BudgetingViewModel(
    this._budgetService,
    this._participantService,
    this._presetService,
    this._appContext,
  );

  List<clientModels.CategoryData> _categories = [];
  List<models.Participant> _allParticipants = [];
  List<models.Template> _templates = [];
  List<BudgetPreset> _availablePresets = [];

  String _searchQuery = '';
  FilterType? _currentFilter;
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
  List<BudgetPreset> get availablePresets => _availablePresets;

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
  }

  bool get hasUnsavedChanges => _categories.isNotEmpty;

  bool get canSave {
    if (_categories.isEmpty) return false;

    bool hasValidCategory = _categories.any((cat) => cat.accounts.isNotEmpty);
    if (!hasValidCategory) return false;

    final names = _categories.map((c) => c.name.trim().toUpperCase()).toList();
    if (names.any((name) => name.isEmpty || name == 'CATEGORY NAME')) {
      return false;
    }
    if (names.length != names.toSet().length) return false;

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

    final names = _categories.map((c) => c.name.trim().toUpperCase()).toList();
    if (names.any((name) => name.isEmpty || name == 'CATEGORY NAME')) {
      return 'All categories must have valid names';
    }
    if (names.length != names.toSet().length) {
      return 'Category names must be unique';
    }

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
      _availablePresets = await _presetService.loadAllPresets();

      final activeTemplate = _appContext.currentTemplate;
      if (activeTemplate != null) {
        debugPrint("Active template found: ${activeTemplate.templateName}");
        await _loadTemplateForEditing(activeTemplate);
      } else {
        _categories = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();

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

    if (activeTemplate != null) {
      final periodStr = activeTemplate.period;
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
      debugPrint("Loading categories for template: ${template.templateName}");
      final categoriesFromDb = await _budgetService.categoryService
          .getCategoriesForTemplate(template.templateId);
      debugPrint("Categories from db (0th): ${categoriesFromDb[0]}");

      final List<clientModels.CategoryData> loadedCategories = [];

      for (var category in categoriesFromDb) {
        final accountsFromDb = await _budgetService.accountService
            .getAccountsForCategory(template.templateId, category.categoryId);
        final List<clientModels.AccountData> accountDataList = [];
        for (var account in accountsFromDb) {
          final participant = account.responsibleParticipantId != null
              ? await _participantService
                  .getParticipant(account.responsibleParticipantId!)
              : null;

          accountDataList.add(clientModels.AccountData(
            id: account.accountId.toString(),
            name: account.accountName,
            budgetAmount: account.budgetAmount,
            participants: participant != null ? [participant] : [],
            color: hexToColor(account.colorHex),
          ));
        }

        loadedCategories.add(clientModels.CategoryData(
          id: category.categoryId.toString(),
          name: category.categoryName,
          color: hexToColor(category.colorHex),
          accounts: accountDataList,
        ));
      }
      debugPrint("Loaded categories (1st): ${loadedCategories[0]}");
      _categories = loadedCategories;

      final periodStr = template.period;
      if (periodStr.startsWith('Custom:')) {
        _selectedPeriod = 'Custom';
        try {
          final parts = periodStr.split(' ');
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
          _selectedPeriod = 'Monthly';
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load template data: $e';
    }
  }

  /// Adopt a preset and convert it to categories
  void adoptPreset(
    BudgetPreset preset, {
    String? period,
    int? customMonths,
  }) {
    clearFilters();

    // If period is provided, update the view model's selected period
    if (period != null) {
      if (period == 'Custom' && customMonths != null) {
        _selectedPeriod = 'Custom';
        _customPeriodMonths = customMonths;
      } else if (periodOptions.contains(period)) {
        _selectedPeriod = period;
        if (period != 'Custom') {
          _customPeriodMonths = 1; // Reset custom months if not custom
        }
      }
    } else {
      // Default to preset's period if not explicitly chosen (though UI should always send it now)
      // If preset period is weird, default to Monthly
      if (periodOptions.contains(preset.period)) {
        _selectedPeriod = preset.period;
      } else if (preset.period.startsWith('Custom')) {
        _selectedPeriod = 'Monthly'; // Fallback
      } else {
        _selectedPeriod = 'Monthly';
      }
    }

    // Calculate the multiplier based on selected period vs preset period
    // Note: We use the newly set _selectedPeriod and _customPeriodMonths
    final multiplier = _presetService.calculatePeriodMultiplier(
      preset.period,
      _selectedPeriod,
      _customPeriodMonths,
    );

    // Scale the preset if needed
    final scaledPreset =
        multiplier != 1.0 ? preset.scaleByMultiplier(multiplier) : preset;

    // Convert preset categories to CategoryData
    final newCategories = <clientModels.CategoryData>[];

    for (var presetCategory in scaledPreset.categories) {
      final categoryColor =
          _presetService.getColorFromName(presetCategory.colorName) ??
              _generateRandomColor();

      final accounts = <clientModels.AccountData>[];
      for (var presetAccount in presetCategory.accounts) {
        accounts.add(clientModels.AccountData(
          id: const Uuid().v4(),
          name: presetAccount.name,
          budgetAmount: presetAccount.budget,
          participants: [],
          color: _generateLighterShade(categoryColor),
        ));
      }

      newCategories.add(clientModels.CategoryData(
        id: const Uuid().v4(),
        name: presetCategory.name,
        color: categoryColor,
        accounts: accounts,
      ));
    }

    _categories = newCategories;
    notifyListeners();
  }

  void addCategory() {
    clearFilters();
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
      _currentFilter = FilterType.name;
    }
    notifyListeners();
  }

  void setFilter(FilterType filter, {SortOrder? order}) {
    if (_currentFilter == filter) {
      if (_sortOrder == SortOrder.asc) {
        _sortOrder = SortOrder.desc;
      } else {
        _currentFilter = null;
        _sortOrder = SortOrder.asc;
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

      for (var category in _categories) {
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
                : null,
            dateCreated: DateTime.now(),
          );

          await _budgetService.accountService.createAccount(newAccount);
        }
      }

      final createdTemplate =
          await _budgetService.templateService.getTemplate(templateId);
      if (createdTemplate != null) {
        await setNewTemplateAsCurrent(createdTemplate);
      } else {
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

    await _loadTemplateForEditing(template);

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
      final periodString = _selectedPeriod == 'Custom'
          ? 'Custom: $_customPeriodMonths Months'
          : _selectedPeriod;

      final templateUpdateData = models.Template(
        templateId: templateId,
        templateName: templateName,
        period: periodString,
        creatorParticipantId: 0,
        dateCreated: DateTime.now(),
      );

      final success = await _budgetService.templateService
          .updateTemplate(templateUpdateData);

      if (!success) {
        throw Exception('Failed to update template details');
      }

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

      for (var categoryData in _categories) {
        final categoryIdInt = int.tryParse(categoryData.id);

        if (categoryIdInt != null &&
            existingCategories.any((c) => c.categoryId == categoryIdInt)) {
          final updatedCategory = models.Category(
            categoryId: categoryIdInt,
            templateId: templateId,
            categoryName: categoryData.name,
            colorHex: _colorToHex(categoryData.color),
          );

          await _budgetService.categoryService.updateCategory(updatedCategory);

          final existingAccounts = await _budgetService.accountService
              .getAccountsForCategory(templateId, categoryIdInt);

          final currentAccountIds = categoryData.accounts
              .map((a) => int.tryParse(a.id))
              .where((id) => id != null)
              .toSet();

          final accountsToDelete = existingAccounts
              .where((a) => !currentAccountIds.contains(a.accountId))
              .toList();

          for (var account in accountsToDelete) {
            await _budgetService.accountService
                .deleteAccount(account.accountId);
          }

          for (var accountData in categoryData.accounts) {
            final accountIdInt = int.tryParse(accountData.id);
            if (accountIdInt != null &&
                existingAccounts.any((a) => a.accountId == accountIdInt)) {
              final existingAccount = existingAccounts
                  .firstWhere((a) => a.accountId == accountIdInt);

              final modifiedAccount = models.Account(
                accountId: accountIdInt,
                categoryId: categoryIdInt,
                templateId: templateId,
                accountName: accountData.name,
                colorHex: _colorToHex(accountData.color),
                budgetAmount: accountData.budgetAmount,
                expenditureTotal: existingAccount.expenditureTotal,
                responsibleParticipantId: accountData.participants.isNotEmpty
                    ? accountData.participants.first.participantId
                    : null,
                dateCreated: existingAccount.dateCreated,
              );
              await _budgetService.accountService
                  .modifyAccount(modifiedAccount);
            } else {
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

  List<clientModels.CategoryData> _filteredAndSortedCategories() {
    var filtered = _categories.where((category) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = category.name.toLowerCase().contains(query);
        final accountMatch = category.accounts.any(
          (a) => a.name.toLowerCase().contains(query),
        );
        if (!nameMatch && !accountMatch) return false;
      }

      if (_filterParticipant != null) {
        final hasParticipant = category.accounts.any(
          (a) => a.participants
              .any((p) => p.participantId == _filterParticipant!.participantId),
        );
        if (!hasParticipant) return false;
      }

      if (_filterColor != null) {
        if (category.color.value != _filterColor!.value) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      if (_currentFilter == FilterType.name) {
        final isANew = a.id == _newlyAddedCategoryId;
        final isBNew = b.id == _newlyAddedCategoryId;

        if (isANew && !isBNew) return 1;
        if (!isANew && isBNew) return -1;
      } else if (_currentFilter == null) {
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
