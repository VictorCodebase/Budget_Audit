import 'package:flutter/material.dart';
import '../../core/models/models.dart' as models;
import '../../core/services/budget_service.dart';
import '../../core/services/participant_service.dart';
import '../../core/services/service_locator.dart';

enum FilterType { name, totalBudget, participant, color }

enum SortOrder { asc, desc }

class CategoryData {
  String id;
  String name;
  Color color;
  List<AccountData> accounts;
  String? validationError;

  CategoryData({
    required this.id,
    required this.name,
    required this.color,
    List<AccountData>? accounts,
    this.validationError,
  }) : accounts = accounts ?? [];

  double get totalBudget =>
      accounts.fold(0.0, (sum, account) => sum + account.budgetAmount);

  Set<models.Participant> get allParticipants =>
      accounts.expand((a) => a.participants).toSet();

  CategoryData copyWith({
    String? id,
    String? name,
    Color? color,
    List<AccountData>? accounts,
    String? validationError,
  }) {
    return CategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      accounts: accounts ?? this.accounts,
      validationError: validationError,
    );
  }
}

class AccountData {
  String id;
  String name;
  double budgetAmount;
  List<models.Participant> participants;
  Color color;
  String? validationError;

  AccountData({
    required this.id,
    required this.name,
    required this.budgetAmount,
    List<models.Participant>? participants,
    required this.color,
    this.validationError,
  }) : participants = participants ?? [];

  AccountData copyWith({
    String? id,
    String? name,
    double? budgetAmount,
    List<models.Participant>? participants,
    Color? color,
    String? validationError,
  }) {
    return AccountData(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      participants: participants ?? this.participants,
      color: color ?? this.color,
      validationError: validationError,
    );
  }
}

class BudgetingViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final ParticipantService _participantService;

  BudgetingViewModel(this._budgetService, this._participantService);

  List<CategoryData> _categories = [];
  List<models.Participant> _allParticipants = [];
  List<models.Template> _templates = [];

  String _searchQuery = '';
  FilterType _currentFilter = FilterType.name;
  SortOrder _sortOrder = SortOrder.asc;
  models.Participant? _filterParticipant;
  Color? _filterColor;

  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryData> get categories => _filteredAndSortedCategories();
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
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCategory() {
    final newCategory = CategoryData(
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

      _categories[index] = _categories[index].copyWith(accounts: updatedAccounts);
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
      final newAccount = AccountData(
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
        updatedAccounts[accIndex] = updatedAccounts[accIndex].copyWith(name: newName);
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
        updatedAccounts[accIndex] = updatedAccounts[accIndex].copyWith(budgetAmount: amount);
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
      final updatedAccounts = category.accounts.where((a) => a.id != accountId).toList();
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

  Future<void> adoptTemplate(models.Template template, int participantId) async {
    // This will be implemented when you finalize the save mechanism
    // For now, it's a placeholder
    _errorMessage = 'Template adoption not yet implemented';
    notifyListeners();
  }

  Future<void> deleteTemplate(int templateId) async {
    try {
      final success = await _budgetService.templateService.deleteTemplate(templateId);
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

  List<CategoryData> _filteredAndSortedCategories() {
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
              (a) => a.participants.any((p) => p.participantId == _filterParticipant!.participantId),
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
          comparison = a.allParticipants.length.compareTo(b.allParticipants.length);
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