
import 'package:flutter/foundation.dart';
import '../../core/services/participant_service.dart';
import '../../core/models/models.dart' as models;
import '../../core/models/client_models.dart' as client_models;
import '../../core/services/service_locator.dart';
import 'package:logging/logging.dart';


enum OnboardingMode {
  addParticipants,
  signInAsParticipant,
}

class OnboardingViewModel extends ChangeNotifier {
  final ParticipantService _participantService;

  OnboardingViewModel(this._participantService);

  // State management
  OnboardingMode _mode = OnboardingMode.addParticipants;
  OnboardingMode get mode => _mode;

  bool _passwordObscured = true;
  bool get passwordObscured => _passwordObscured;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // List of participants (for display on the right side)
  List<models.Participant> _participants = [];
  List<models.Participant> get participants => _participants;

  // Current participant being added/edited
  int? _editingParticipantId;
  int? get editingParticipantId => _editingParticipantId;

  // Form state
  final Map<String, String> _formData = {
    'firstName': '',
    'lastName': '',
    'nickname': '',
    'email': '',
    'password': '',
  };

  String getFormValue(String field) => _formData[field] ?? '';

  // Track if this is the first participant (owner/manager)
  bool get isFirstParticipant => _participants.isEmpty;

  // ========== Initialization ==========

  Future<void> initialize() async {
    await loadParticipants();
  }

  Future<void> loadParticipants() async {
    _setLoading(true);
    try {
      _participants = await _participantService.getAllParticipants();
      _clearError();
    } catch (e) {
      _setError('Failed to load participants: $e');
    } finally {
      _setLoading(false);
    }
  }

  void onToggleObscure(){
    _passwordObscured = !_passwordObscured;
    notifyListeners();
  }

  // ========== Mode Switching ==========

  void switchMode(OnboardingMode newMode) {

    _mode = newMode;
    _clearForm();
    _clearError();
    notifyListeners();
  }

  // ========== Form Management ==========

  void updateFormField(String field, String value) {
    _formData[field] = value;
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

    // Password validation (for now, just check if not empty)
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ========== Add Participant ==========

  Future<bool> createNewParticipant() async {
    final validationError = validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      // Determine role based on whether this is the first participant
      final role = isFirstParticipant
          ? client_models.Role.manager
          : client_models.Role.participant;

      final participant = client_models.Participant(
        firstName: _formData['firstName']!.trim(),
        lastName: _formData['lastName']?.trim().isEmpty == true
            ? null
            : _formData['lastName']?.trim(),
        nickname: _formData['nickname']?.trim().isEmpty == true
            ? null
            : _formData['nickname']?.trim(),
        role: role,
        email: _formData['email']!.trim(),
      );

      // TODO: Hash password before storing!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      final participantId = await _participantService.addParticipant(
        participant,
        _formData['password']!,
      );

      if (participantId > 0) {
        await loadParticipants();
        _clearForm();
        _clearError();
        return true;
      } else {
        _setError('Failed to create participant');
        return false;
      }
    } catch (e) {
      _setError('Error creating participant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Edit Participant ==========

  void startEditingParticipant(models.Participant participant) {
    _editingParticipantId = participant.participantId;
    _formData['firstName'] = participant.firstName;
    _formData['lastName'] = participant.lastName ?? '';
    _formData['nickname'] = participant.nickname ?? '';
    _formData['email'] = participant.email;
    _formData['password'] = ''; // Don't populate password for security
    notifyListeners();
  }


  /// Update an existing participant
  Future<bool> updateExistingParticipant() async {
    if (_editingParticipantId == null) return false;

    final validationError = validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      final participant = models.Participant(
        participantId: _editingParticipantId!,
        firstName: _formData['firstName']!.trim(),
        lastName: _formData['lastName']?.trim().isEmpty == true
            ? null
            : _formData['lastName']?.trim(),
        nickname: _formData['nickname']?.trim().isEmpty == true
            ? null
            : _formData['nickname']?.trim(),
        role: _participants
            .firstWhere((p) => p.participantId == _editingParticipantId)
            .role,
        email: _formData['email']!.trim(),
      );

      // Only pass password if it was actually entered
      final newPassword = _formData['password']?.trim();
      final passwordToUpdate = (newPassword != null && newPassword.isNotEmpty)
          ? newPassword
          : null;

      final success = await _participantService.updateParticipant(
        participant,
        newPassword: passwordToUpdate,
      );

      if (success) {
        await loadParticipants();
        _clearForm();
        _clearError();
        notifyListeners(); // Ensure UI updates
        return true;
      } else {
        _setError('Failed to update participant');
        return false;
      }
    } catch (e) {
      _setError('Error updating participant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel editing and return to add mode
  void cancelEditing() {
    _editingParticipantId = null;
    _clearForm();
    _clearError();
    notifyListeners();
  }

  /// Check if currently in edit mode
  bool get isEditMode => _editingParticipantId != null;


  // ========== Delete Participant ==========

  Future<bool> removeParticipant(int participantId) async {
    _setLoading(true);
    // Prevent deleting the manager/owner
    final participant = _participants.firstWhere(
          (p) => p.participantId == participantId,
    );

    if (participant.role == models.Role.manager) {
      _setError('Cannot delete the owner account');
      return false;
    }

    _setLoading(true);
    try {
      _participantService.deleteParticipant(participant);
      _participants.removeWhere((p) => p.participantId == participantId);

      // If we were editing this participant, clear the edit state
      if (_editingParticipantId == participantId) {
        _clearForm();
      }
      await loadParticipants();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error deleting participant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Sign In ==========

  Future<models.Participant?> signInAsParticipant(
      String email,
      String password,
      ) async {
    _setLoading(true);
    try {
      // Find participant by email
      final participant = _participants.firstWhere(
            (p) => p.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('Participant not found'),
      );

      // TODO: Verify password hash
      // For now, we'll just return the participant
      // You need to implement proper password verification

      _clearError();
      return participant;
    } catch (e) {
      _setError('Invalid email or password');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Navigation Helpers ==========

  bool canProceed() {
    // Must have at least one participant (the manager/owner)
    return _participants.isNotEmpty;
  }

  String getNextRoute() {
    // Check if any templates/budgets exist
    // For now, always route to budgeting page after onboarding
    // You can enhance this later to check for existing budgets
    return '/budgeting';
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


}

