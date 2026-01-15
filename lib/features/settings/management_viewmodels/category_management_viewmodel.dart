import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../../core/models/models.dart' as models;
import '../../../core/services/budget_service.dart';
import '../../../core/services/participant_service.dart';
import '../../../core/context.dart';

/// Manages category viewing, editing, and deletion in settings
/// Shows categories from templates the user has access to
class CategoryManagementViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final ParticipantService _participantService;
  final AppContext _appContext;
  final Logger _logger = Logger("CategoryManagementViewModel");

  CategoryManagementViewModel(
    this._budgetService,
    this._participantService,
    this._appContext,
  );

  // ========== State Management ==========

  // Cache of categories per template
  final Map<int, List<models.Category>> _templateCategories = {};

  // Track which templates are currently loading
  final Set<int> _loadingTemplateIds = {};

  // For backward compatibility / ease of use when editing
  List<models.Category> get categories {
    if (_selectedTemplateId != null) {
      return _templateCategories[_selectedTemplateId] ?? [];
    }
    return [];
  }

  List<models.Template> _accessibleTemplates = [];
  List<models.Template> get accessibleTemplates => _accessibleTemplates;

  int? _selectedTemplateId;
  int? get selectedTemplateId => _selectedTemplateId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ========== Current User Info ==========

  models.Participant? get currentUser => _appContext.currentParticipant;
  bool get isManager => currentUser?.role == models.Role.manager;

  // ========== Form State ==========

  int? _editingCategoryId;
  int? get editingCategoryId => _editingCategoryId;
  bool get isEditMode => _editingCategoryId != null;

  final Map<String, String> _formData = {
    'categoryName': '',
    'colorHex': '',
  };

  String getFormValue(String field) => _formData[field] ?? '';

  // ========== Initialization ==========

  /// Load templates and categories based on user access
  Future<void> initialize() async {
    await loadAccessibleTemplates();
    if (_accessibleTemplates.isNotEmpty) {
      await selectTemplate(_accessibleTemplates.first.templateId);
    }
  }

  /// Load all templates the user has access to
  Future<void> loadAccessibleTemplates() async {
    _setLoading(true);
    try {
      final allTemplates =
          await _budgetService.templateService.getAllTemplates();

      if (isManager) {
        // Manager sees all templates
        _accessibleTemplates = allTemplates;
      } else if (currentUser != null) {
        // Regular users see only templates they're part of
        _accessibleTemplates = [];
        for (final template in allTemplates) {
          final participants =
              await _participantService.getTemplateParticipants(
            template.templateId,
          );
          if (participants
              .any((p) => p.participantId == currentUser!.participantId)) {
            _accessibleTemplates.add(template);
          }
        }
      } else {
        _accessibleTemplates = [];
      }

      _clearError();
      _logger
          .info('Loaded ${_accessibleTemplates.length} accessible templates');
    } catch (e) {
      _logger.severe('Failed to load accessible templates', e);
      _setError('Failed to load templates: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select a template and load its categories
  Future<void> selectTemplate(int templateId) async {
    _selectedTemplateId = templateId;
    await loadCategoriesForTemplate(templateId);
  }

  /// Get categories for a specific template from cache
  List<models.Category> getCategoriesForTemplate(int templateId) {
    return _templateCategories[templateId] ?? [];
  }

  /// Check if a template is currently loading
  bool isTemplateLoading(int templateId) {
    return _loadingTemplateIds.contains(templateId);
  }

  /// Check if a template has been loaded
  bool isTemplateLoaded(int templateId) {
    return _templateCategories.containsKey(templateId);
  }

  /// Load categories for a specific template
  Future<void> loadCategoriesForTemplate(int templateId,
      {bool force = false}) async {
    // Skip if already loading
    if (_loadingTemplateIds.contains(templateId)) return;

    // Skip if already loaded and not forcing refresh
    if (!force && _templateCategories.containsKey(templateId)) return;

    _loadingTemplateIds.add(templateId);
    // Only set global loading if this is the selected template
    if (_selectedTemplateId == templateId) {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final loadedCategories =
          await _budgetService.categoryService.getCategoriesForTemplate(
        templateId,
      );

      _templateCategories[templateId] = loadedCategories;

      // If error was for this template, clear it
      if (_selectedTemplateId == templateId) {
        _clearError();
        _logger.info(
            'Loaded ${loadedCategories.length} categories for template $templateId');
      }
    } catch (e) {
      _logger.severe('Failed to load categories for template $templateId', e);
      if (_selectedTemplateId == templateId) {
        _setError('Failed to load categories: $e');
      }
    } finally {
      _loadingTemplateIds.remove(templateId);
      if (_selectedTemplateId == templateId) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  // ========== Form Management ==========

  void updateFormField(String field, String value) {
    _formData[field] = value;
    notifyListeners();
  }

  void _clearForm() {
    _formData.clear();
    _formData.addAll({
      'categoryName': '',
      'colorHex': '',
    });
    _editingCategoryId = null;
  }

  // ========== Validation ==========

  String? validateForm() {
    final categoryName = _formData['categoryName']?.trim() ?? '';
    final colorHex = _formData['colorHex']?.trim() ?? '';

    if (categoryName.isEmpty) {
      return 'Category name is required';
    }

    if (colorHex.isEmpty) {
      return 'Color is required';
    }

    // Validate hex color format
    final hexRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!hexRegex.hasMatch(colorHex)) {
      return 'Invalid color format (use #RRGGBB or #AARRGGBB)';
    }

    return null;
  }

  // ========== Edit Category ==========

  /// Start editing a category
  void startEditing(models.Category category) {
    _editingCategoryId = category.categoryId;
    _formData['categoryName'] = category.categoryName;
    _formData['colorHex'] = category.colorHex;
    _clearError();
    notifyListeners();
  }

  /// Update an existing category
  /// Returns true if successful
  Future<bool> updateCategory() async {
    if (_editingCategoryId == null) return false;

    final validationError = validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      final existingCategories = _templateCategories[_selectedTemplateId] ?? [];
      final existingCategory = existingCategories.firstWhere(
        (c) => c.categoryId == _editingCategoryId,
      );

      final category = models.Category(
        categoryId: _editingCategoryId!,
        templateId: existingCategory.templateId,
        categoryName: _formData['categoryName']!.trim(),
        colorHex: _formData['colorHex']!.trim(),
      );

      final success =
          await _budgetService.categoryService.updateCategory(category);

      if (success) {
        _logger.info('Successfully updated category: $_editingCategoryId');

        if (_selectedTemplateId != null) {
          // Refresh the template the updated category belongs to
          await loadCategoriesForTemplate(category.templateId, force: true);
          // Also refresh current if different (edge case)
          if (_selectedTemplateId != category.templateId) {
            await loadCategoriesForTemplate(_selectedTemplateId!, force: true);
          }
        } else {
          await loadCategoriesForTemplate(category.templateId, force: true);
        }

        _clearForm();
        _clearError();
        return true;
      } else {
        _setError('Failed to update category');
        return false;
      }
    } catch (e) {
      _logger.severe('Error updating category', e);
      _setError('Error updating category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel editing and clear form
  void cancelEditing() {
    _editingCategoryId = null;
    _clearForm();
    _clearError();
    notifyListeners();
  }

  // ========== Delete Category ==========

  /// Delete a category and all its accounts
  /// Returns true if successful
  Future<bool> deleteCategory(models.Category category) async {
    _setLoading(true);
    try {
      final success = await _budgetService.categoryService.deleteCategory(
        category.categoryId,
      );

      if (success) {
        _logger.info('Successfully deleted category: ${category.categoryId}');

        // If we were editing this category, clear the edit state
        if (_editingCategoryId == category.categoryId) {
          _clearForm();
        }

        // Refresh the template the deleted category belonged to
        await loadCategoriesForTemplate(category.templateId, force: true);

        if (_selectedTemplateId != null &&
            _selectedTemplateId != category.templateId) {
          await loadCategoriesForTemplate(_selectedTemplateId!, force: true);
        }

        _clearError();
        return true;
      } else {
        _setError('Failed to delete category');
        return false;
      }
    } catch (e) {
      _logger.severe('Error deleting category', e);
      _setError('Error deleting category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Helper Methods ==========

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get template name by ID
  String? getTemplateName(int templateId) {
    try {
      return _accessibleTemplates
          .firstWhere((t) => t.templateId == templateId)
          .templateName;
    } catch (e) {
      return null;
    }
  }

  /// Get account count for a category
  Future<int> getAccountCount(int categoryId, int templateId) async {
    try {
      final accounts =
          await _budgetService.accountService.getAccountsForCategory(
        templateId,
        categoryId,
      );
      return accounts.length;
    } catch (e) {
      _logger.severe('Error getting account count', e);
      return 0;
    }
  }
}
