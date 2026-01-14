import 'package:flutter/foundation.dart';
import '../../core/services/participant_service.dart';
import '../../core/models/models.dart' as models;
import '../../core/models/client_models.dart' as client_models;
import 'package:logging/logging.dart';
import '../../core/context.dart';

class OnboardingViewModel extends ChangeNotifier {
  final ParticipantService _participantService;
  final AppContext _appContext;
  final Logger _logger = Logger("OnboardingViewModel");

  OnboardingViewModel(this._participantService, this._appContext);

  // ========== State Management ==========

  bool _passwordObscured = true;
  bool get passwordObscured => _passwordObscured;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<models.Participant> _participants = [];
  List<models.Participant> get participants => _participants;

  // Form state
  final Map<String, String> _formData = {
    'firstName': '',
    'lastName': '',
    'nickname': '',
    'email': '',
    'password': '',
  };

  String getFormValue(String field) => _formData[field] ?? '';

  /// Check if this is the first participant (determines if we show signup or login)
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

  void onToggleObscure() {
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
  }

  // ========== Validation ==========

  String? _validateForm() {
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

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ========== Create First Admin Account ==========

  /// Create the first participant (admin/manager account)
  /// Only available when no participants exist
  Future<bool> createNewParticipant() async {
    // Validate that this is truly the first participant
    if (!isFirstParticipant) {
      _setError('Account creation is only available for the first user');
      return false;
    }

    final validationError = _validateForm();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);
    try {
      // First participant is always a manager
      final participant = client_models.Participant(
        firstName: _formData['firstName']!.trim(),
        lastName: _formData['lastName']?.trim().isEmpty == true
            ? null
            : _formData['lastName']?.trim(),
        nickname: _formData['nickname']?.trim().isEmpty == true
            ? null
            : _formData['nickname']?.trim(),
        role: client_models.Role.manager,
        email: _formData['email']!.trim(),
      );

      final participantId = await _participantService.addParticipant(
        participant,
        _formData['password']!,
      );

      if (participantId > 0) {
        _logger
            .info('Successfully created admin account with ID: $participantId');
        await loadParticipants();
        _clearError();
        return true;
      } else {
        _setError('Failed to create account');
        return false;
      }
    } catch (e) {
      _logger.severe('Error creating admin account', e);
      _setError('Error creating account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Sign In ==========

  /// Sign in as a participant using email and password
  Future<bool> signInAsParticipant(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _setError('Email and password are required');
      return false;
    }

    _setLoading(true);
    try {
      // Verify credentials
      final isValid =
          await _participantService.verifyParticipant(email, password);

      if (!isValid) {
        _setError('Invalid email or password');
        return false;
      }

      // Fetch the participant details
      final participant = _participants.firstWhere(
        (p) => p.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => throw Exception('Participant not found'),
      );

      // Update app context with signed-in participant
      await _appContext.setParticipant(participant);

      _logger.info('Successfully signed in: ${participant.email}');
      _clearForm();
      _clearError();
      return true;
    } catch (e) {
      _logger.severe('Error during sign in', e);
      _setError('Invalid email or password');
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
}
