import 'package:flutter/material.dart';
import '../../core/context.dart';
import '../../core/models/models.dart' as models;
import '../../core/models/client_models.dart' as clientModels;
import '../../core/services/budget_service.dart';
import '../../core/services/participant_service.dart';
import '../../core/services/service_locator.dart';
import '../../core/utils/hex_to_color.dart';

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
  FilterType _currentFilter = FilterType.name;
  SortOrder _sortOrder = SortOrder.asc;
  models.Participant? _filterParticipant;
  Color? _filterColor;

  bool _isLoading = false;
  String? _errorMessage;

  // Expose services for the view
  AccountService get accountService => _budgetService.accountService;

  ParticipantService get participantService => _participantService;

  List<clientModels.CategoryData> get categories => _filteredAndSortedCategories();

  List<models.Participant> get allParticipants => _allParticipants;

  List<models.Template> get templates => _templates;

  String get searchQuery => _searchQuery;

  FilterType get currentFilter => _currentFilter;

  SortOrder get sortOrder => _sortOrder;

  models.Participant? get filterParticipant => _filterParticipant;

  Color? get filterColor => _filterColor;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

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
      }else {
        // Clear categories if no active template
        _categories = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTemplateForEditing(models.Template template) async {
    try{
      // 1. Load all categories for this template
      debugPrint("Loading categories for template: ${template.templateName}");
      final categoriesFromDb = await _budgetService.categoryService
          .getCategoriesForTemplate(template.templateId);
      debugPrint("Categories from db (0th): ${categoriesFromDb[0]}");

      // 2. Load accounts for each category and convert to local CategoryData
      final List<clientModels.CategoryData> loadedCategories = [];

      for (var category in categoriesFromDb) {
        final accountsFromDb = await _budgetService.accountService
            .getAccountsForCategory(
            template.templateId,
            category.categoryId
        );
        // Convert database accounts to local AccountData
        final List<clientModels.AccountData> accountDataList = [];
        for (var account in accountsFromDb) {
          final participant = await _participantService
              .getParticipant(account.responsibleParticipantId);

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

      // Note: We don't call notifyListeners() here because the calling method will do it.
    } catch (e){
      _errorMessage = 'Failed to load template data: $e';
    }

  }

  void addCategory() {
    final newCategory = clientModels.CategoryData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'CATEGORY NAME',
      color: _generateRandomColor(),
    );
    _categories.add(newCategory);
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Account name',
        budgetAmount: 0.0,
        color: _generateLighterShade(category.color),
      );

      final updatedAccounts = [...category.accounts, newAccount];
      _categories[index] = category.copyWith(accounts: updatedAccounts);
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
    _currentFilter = filter;
    if (order != null) {
      _sortOrder = order;
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

  void toggleSortOrder() {
    _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _currentFilter = FilterType.name;
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
      final newTemplate = clientModels.Template(
        templateName: templateName,
        creatorParticipantId: creatorParticipantId,
        dateCreated: DateTime.now(),
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
                : creatorParticipantId,
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

      // 4. Clear the working categories
      _categories.clear();

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
      // 1. Delete all existing categories and accounts for this template
      final existingCategories = await _budgetService.categoryService
          .getCategoriesForTemplate(templateId);
      for (var category in existingCategories) {
        await _budgetService.categoryService
            .deleteCategory(category.categoryId);
      }

      // 2. Create new categories and accounts (same as save)
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
                : _appContext.currentParticipant!.participantId,
            dateCreated: DateTime.now(),
          );

          await _budgetService.accountService.createAccount(newAccount);
        }
      }

      _isLoading = false;

      final updatedTemplate = await _budgetService.templateService.getTemplate(templateId);
      if(updatedTemplate != null){
        await _loadTemplateForEditing(updatedTemplate);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update template: $e';
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
      }

      return _sortOrder == SortOrder.asc ? comparison : -comparison;
    });

    return filtered;
  }

  Color _generateRandomColor() {
    final colors = [
      const Color(0xFFFF6B9D),
      const Color(0xFF7DD3FC),
      const Color(0xFFA78BFA),
      const Color(0xFF5EEAD4),
      const Color(0xFFFBBF24),
      const Color(0xFFF87171),
      const Color(0xFF34D399),
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
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
