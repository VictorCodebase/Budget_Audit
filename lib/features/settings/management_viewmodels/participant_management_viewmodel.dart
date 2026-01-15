import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../../core/models/models.dart' as models;
import '../../../core/models/client_models.dart' as client_models;
import '../../../core/services/participant_service.dart';
import '../../../core/context.dart';

/// Manages participant CRUD operations in settings
/// Handles both viewing all participants (manager) and editing own profile (all users)
class ParticipantManagementViewModel extends ChangeNotifier {
  final ParticipantService _participantService;
  final AppContext _appContext;
  final Logger _logger = Logger("ParticipantManagementViewModel");

  ParticipantManagementViewModel(
    this._participantService,
    this._appContext,
  );

  // ========== State Management ==========

  List<models.Participant> _participants = [];
  List<models.Participant> get participants => _participants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _passwordObscured = true;
  bool get passwordObscured => _passwordObscured;

  // ========== Current User Info ==========

  models.Participant? get currentUser => _appContext.currentParticipant;
  bool get isManager => currentUser?.role == models.Role.manager;

  // ========== Form State ==========

  int? _editingParticipantId;
  int? get editingParticipantId => _editingParticipantId;
  bool get isEditMode => _editingParticipantId != null;
  bool get isEditingSelf => _editingParticipantId == currentUser?.participantId;

  final Map<String, String> _formData = {
    'firstName': '',
    'lastName': '',
    'nickname': '',
    'email': '',
    'password': '',
  };

  String getFormValue(String field) => _formData[field] ?? '';

  // ========== Initialization ==========

  /// Load all participants
  /// Managers see all, regular users see only themselves
  Future<void> initialize() async {
    await loadParticipants();
  }

  Future<void> loadParticipants() async {
    _setLoading(true);
    try {
      final allParticipants = await _participantService.getAllParticipants();

      // If not manager, filter to show only current user
      if (isManager) {
        _participants = allParticipants;
      } else {
        _participants = allParticipants
            .where((p) => p.participantId == currentUser?.participantId)
            .toList();
      }

      _clearError();
      _logger.info('Loaded ${_participants.length} participants');
    } catch (e) {
      _logger.severe('Failed to load participants', e);
      _setError('Failed to load participants: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== Form Management ==========

  void updateFormField(String field, String value) {
    _formData[field] = value;
    notifyListeners();
  }

  void togglePasswordObscured() {
    _passwordObscured = !_passwordObscured;
    notifyListeners();
  }

  void _clearForm() {
    _formData.clear();
    _formData.addAll({
      'firstName': '',
      'lastName': '',
      'nickname': '',
      'email': '',
      'password': '',
    });
    _editingParticipantId = null;
  }

  // ========== Validation ==========

  String? validateForm() {
    final firstName = _formData['firstName']?.trim() ?? '';
    final email = _formData['email']?.trim() ?? '';
    final password = _formData['password']?.trim() ?? '';

    if (firstName.isEmpty) {
      return 'First name is required';
    }

    if (email.isEmpty) {
      return 'Email is required';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Password validation only for new participants or when changing password
    if (!isEditMode && password.isEmpty) {
      return 'Password is required';
    }

    if (password.isNotEmpty && password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ========== Add Participant ==========

  /// Add a new participant (manager only)
  /// Returns true if successful
  Future<bool> addParticipant() async {
    if (!isManager) {
      _setError('Only managers can add participants');
      return false;
    }

    final validationError = validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      final participant = client_models.Participant(
        firstName: _formData['firstName']!.trim(),
        lastName: _formData['lastName']?.trim().isEmpty == true
            ? null
            : _formData['lastName']?.trim(),
        nickname: _formData['nickname']?.trim().isEmpty == true
            ? null
            : _formData['nickname']?.trim(),
        role: client_models.Role
            .participant, // New participants are always regular participants
        email: _formData['email']!.trim(),
      );

      final participantId = await _participantService.addParticipant(
        participant,
        _formData['password']!,
      );

      if (participantId > 0) {
        _logger.info('Successfully added participant with ID: $participantId');
        await loadParticipants();
        _clearForm();
        _clearError();
        return true;
      } else {
        _setError('Failed to add participant');
        return false;
      }
    } catch (e) {
      _logger.severe('Error adding participant', e);
      _setError('Error adding participant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Edit Participant ==========

  /// Start editing a participant
  /// Managers can edit anyone, regular users can only edit themselves
  void startEditing(models.Participant participant) {
    // Check permissions
    if (!isManager && participant.participantId != currentUser?.participantId) {
      _setError('You can only edit your own profile');
      return;
    }

    _editingParticipantId = participant.participantId;
    _formData['firstName'] = participant.firstName;
    _formData['lastName'] = participant.lastName ?? '';
    _formData['nickname'] = participant.nickname ?? '';
    _formData['email'] = participant.email;
    _formData['password'] = ''; // Never populate password
    _clearError();
    notifyListeners();
  }

  /// Update an existing participant
  /// Returns true if successful
  Future<bool> updateParticipant() async {
    if (_editingParticipantId == null) return false;

    // Check permissions
    if (!isManager && _editingParticipantId != currentUser?.participantId) {
      _setError('You can only edit your own profile');
      return false;
    }

    final validationError = validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      final existingParticipant = _participants.firstWhere(
        (p) => p.participantId == _editingParticipantId,
      );

      final participant = models.Participant(
        participantId: _editingParticipantId!,
        firstName: _formData['firstName']!.trim(),
        lastName: _formData['lastName']?.trim().isEmpty == true
            ? null
            : _formData['lastName']?.trim(),
        nickname: _formData['nickname']?.trim().isEmpty == true
            ? null
            : _formData['nickname']?.trim(),
        role: existingParticipant.role, // Preserve existing role
        email: _formData['email']!.trim(),
      );

      // Only pass password if it was actually entered
      final newPassword = _formData['password']?.trim();
      final passwordToUpdate =
          (newPassword != null && newPassword.isNotEmpty) ? newPassword : null;

      final success = await _participantService.updateParticipant(
        participant,
        newPassword: passwordToUpdate,
      );

      if (success) {
        _logger
            .info('Successfully updated participant: $_editingParticipantId');

        // If user updated their own profile, update context
        if (_editingParticipantId == currentUser?.participantId) {
          await _appContext.setParticipant(participant);
        }

        await loadParticipants();
        _clearForm();
        _clearError();
        return true;
      } else {
        _setError('Failed to update participant');
        return false;
      }
    } catch (e) {
      _logger.severe('Error updating participant', e);
      _setError('Error updating participant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel editing and clear form
  void cancelEditing() {
    _editingParticipantId = null;
    _clearForm();
    _clearError();
    notifyListeners();
  }

  // ========== Delete Participant ==========

  /// Delete a participant
  /// Managers can delete anyone except themselves
  /// Regular users can delete themselves (which logs them out)
  /// Returns true if successful
  Future<bool> deleteParticipant(models.Participant participant) async {
    final participantId = participant.participantId;
    final isDeletingSelf = participantId == currentUser?.participantId;

    // Prevent manager from deleting themselves
    if (isDeletingSelf && isManager) {
      _setError('Managers cannot delete their own account');
      return false;
    }

    // Check permissions - only manager can delete others
    if (!isDeletingSelf && !isManager) {
      _setError('You can only delete your own account');
      return false;
    }

    _setLoading(true);
    try {
      final success = await _participantService.deleteParticipant(participant);

      if (success) {
        _logger.info('Successfully deleted participant: $participantId');

        // If user deleted their own account, sign them out
        if (isDeletingSelf) {
          await _appContext.signOut();
          _logger.info('User deleted their account and was signed out');
        } else {
          // If we were editing this participant, clear the edit state
          if (_editingParticipantId == participantId) {
            _clearForm();
          }
          await loadParticipants();
        }

        _clearError();
        return true;
      } else {
        _setError('Failed to delete participant');
        return false;
      }
    } catch (e) {
      _logger.severe('Error deleting participant', e);
      _setError('Error deleting participant: $e');
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

  String getDisplayName(models.Participant participant) {
    if (participant.nickname != null && participant.nickname!.isNotEmpty) {
      return participant.nickname!;
    }
    return participant.firstName;
  }

  String getFullName(models.Participant participant) {
    final parts = [
      participant.firstName,
      if (participant.lastName != null) participant.lastName!,
    ];
    return parts.join(' ');
  }

  /// Get role display string
  String getRoleDisplay(models.Participant participant) {
    return participant.role.value.toUpperCase();
  }
}
