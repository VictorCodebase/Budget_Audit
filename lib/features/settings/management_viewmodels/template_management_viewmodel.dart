import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../../core/models/models.dart' as models;
import '../../../core/services/budget_service.dart';
import '../../../core/services/participant_service.dart';
import '../../../core/context.dart';

/// Manages template viewing, editing, and deletion in settings
/// Managers see all templates, regular users see only templates they're part of
class TemplateManagementViewModel extends ChangeNotifier {
  final BudgetService _budgetService;
  final ParticipantService _participantService;
  final AppContext _appContext;
  final Logger _logger = Logger("TemplateManagementViewModel");

  TemplateManagementViewModel(
    this._budgetService,
    this._participantService,
    this._appContext,
  );

  // ========== State Management ==========

  List<models.Template> _templates = [];
  List<models.Template> get templates => _templates;

  Map<int, List<models.Participant>> _templateParticipants = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ========== Current User Info ==========

  models.Participant? get currentUser => _appContext.currentParticipant;
  bool get isManager => currentUser?.role == models.Role.manager;

  // ========== Form State ==========

  int? _editingTemplateId;
  int? get editingTemplateId => _editingTemplateId;
  bool get isEditMode => _editingTemplateId != null;

  final Map<String, String> _formData = {
    'templateName': '',
    'period': '',
  };

  String getFormValue(String field) => _formData[field] ?? '';

  // ========== Initialization ==========

  /// Load templates based on user role
  /// Managers see all, regular users see only templates they're part of
  Future<void> initialize() async {
    await loadTemplates();
  }

  Future<void> loadTemplates() async {
    _setLoading(true);
    try {
      final allTemplates =
          await _budgetService.templateService.getAllTemplates();

      if (isManager) {
        // Manager sees all templates
        _templates = allTemplates;
      } else if (currentUser != null) {
        // Regular users see only templates they're part of
        _templates = [];
        for (final template in allTemplates) {
          final participants =
              await _participantService.getTemplateParticipants(
            template.templateId,
          );
          if (participants
              .any((p) => p.participantId == currentUser!.participantId)) {
            _templates.add(template);
            _templateParticipants[template.templateId] = participants;
          }
        }
      } else {
        _templates = [];
      }

      _clearError();
      _logger.info('Loaded ${_templates.length} templates');
    } catch (e) {
      _logger.severe('Failed to load templates', e);
      _setError('Failed to load templates: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load participants for a specific template
  Future<List<models.Participant>> getTemplateParticipants(
      int templateId) async {
    // Return cached if available
    if (_templateParticipants.containsKey(templateId)) {
      return _templateParticipants[templateId]!;
    }

    try {
      final participants =
          await _participantService.getTemplateParticipants(templateId);
      _templateParticipants[templateId] = participants;
      return participants;
    } catch (e) {
      _logger.severe('Failed to load participants for template $templateId', e);
      return [];
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
      'templateName': '',
      'period': '',
    });
    _editingTemplateId = null;
  }

  // ========== Validation ==========

  String? validateForm() {
    final templateName = _formData['templateName']?.trim() ?? '';
    final period = _formData['period']?.trim() ?? '';

    if (templateName.isEmpty) {
      return 'Template name is required';
    }

    if (period.isEmpty) {
      return 'Period is required';
    }

    return null;
  }

  // ========== Edit Template ==========

  /// Start editing a template
  /// Only users who are part of the template (or managers) can edit
  void startEditing(models.Template template) {
    _editingTemplateId = template.templateId;
    _formData['templateName'] = template.templateName;
    _formData['period'] = template.period;
    _clearError();
    notifyListeners();
  }

  /// Update an existing template
  /// Returns true if successful
  Future<bool> updateTemplate() async {
    if (_editingTemplateId == null) return false;

    final validationError = validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      final existingTemplate = _templates.firstWhere(
        (t) => t.templateId == _editingTemplateId,
      );

      final template = models.Template(
        templateId: _editingTemplateId!,
        syncId: existingTemplate.syncId,
        spreadSheetId: existingTemplate.spreadSheetId,
        templateName: _formData['templateName']!.trim(),
        creatorParticipantId: existingTemplate.creatorParticipantId,
        dateCreated: existingTemplate.dateCreated,
        timesUsed: existingTemplate.timesUsed,
        period: _formData['period']!.trim(),
      );

      final success =
          await _budgetService.templateService.updateTemplate(template);

      if (success) {
        _logger.info('Successfully updated template: $_editingTemplateId');

        // If this is the current template in context, update it
        if (_appContext.currentTemplate?.templateId == _editingTemplateId) {
          await _appContext.setCurrentTemplate(template);
        }

        await loadTemplates();
        _clearForm();
        _clearError();
        return true;
      } else {
        _setError('Failed to update template');
        return false;
      }
    } catch (e) {
      _logger.severe('Error updating template', e);
      _setError('Error updating template: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel editing and clear form
  void cancelEditing() {
    _editingTemplateId = null;
    _clearForm();
    _clearError();
    notifyListeners();
  }

  // ========== Delete Template ==========

  /// Delete a template
  /// Only managers or the template creator can delete
  /// Returns true if successful
  Future<bool> deleteTemplate(models.Template template) async {
    final templateId = template.templateId;

    // Check permissions: must be manager or creator
    final canDelete = isManager ||
        template.creatorParticipantId == currentUser?.participantId;

    if (!canDelete) {
      _setError('Only the template creator or managers can delete templates');
      return false;
    }

    _setLoading(true);
    try {
      final success =
          await _budgetService.templateService.deleteTemplate(templateId);

      if (success) {
        _logger.info('Successfully deleted template: $templateId');

        // If this was the current template in context, clear it
        if (_appContext.currentTemplate?.templateId == templateId) {
          await _appContext.clearCurrentTemplate();
        }

        // If we were editing this template, clear the edit state
        if (_editingTemplateId == templateId) {
          _clearForm();
        }

        await loadTemplates();
        _clearError();
        return true;
      } else {
        _setError('Failed to delete template');
        return false;
      }
    } catch (e) {
      _logger.severe('Error deleting template', e);
      _setError('Error deleting template: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Template Participants Management ==========

  /// Add a participant to a template (manager only)
  Future<bool> addParticipantToTemplate({
    required int templateId,
    required int participantId,
  }) async {
    if (!isManager) {
      _setError('Only managers can add participants to templates');
      return false;
    }

    try {
      final success = await _participantService.addParticipantToTemplate(
        templateId: templateId,
        participantId: participantId,
        permissionRole: 'participant', // Default role
      );

      if (success) {
        // Refresh participants for this template
        _templateParticipants.remove(templateId);
        await getTemplateParticipants(templateId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _logger.severe('Error adding participant to template', e);
      _setError('Error adding participant: $e');
      return false;
    }
  }

  /// Remove a participant from a template (manager only)
  Future<bool> removeParticipantFromTemplate({
    required int templateId,
    required int participantId,
  }) async {
    if (!isManager) {
      _setError('Only managers can remove participants from templates');
      return false;
    }

    try {
      final success = await _participantService.removeParticipantFromTemplate(
        templateId: templateId,
        participantId: participantId,
      );

      if (success) {
        // Refresh participants for this template
        _templateParticipants.remove(templateId);
        await getTemplateParticipants(templateId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _logger.severe('Error removing participant from template', e);
      _setError('Error removing participant: $e');
      return false;
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

  /// Get total budget for a template
  Future<double> getTemplateTotalBudget(int templateId) async {
    try {
      return await _budgetService.accountService
          .getTemplateTotalBudget(templateId);
    } catch (e) {
      _logger.severe('Error getting template budget', e);
      return 0.0;
    }
  }

  /// Get template creator name
  Future<String?> getCreatorName(int creatorId) async {
    try {
      final creator = await _participantService.getParticipant(creatorId);
      if (creator != null) {
        return creator.nickname ?? creator.firstName;
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting creator name', e);
      return null;
    }
  }
}
