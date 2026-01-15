import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../core/models/models.dart' as models;
import '../../core/context.dart';
import '../../core/services/participant_service.dart';
import '../../core/services/budget_service.dart';

/// Main coordinator for the Settings feature
/// Manages navigation between different settings sections and provides
/// common state like current user and role-based permissions
class SettingsViewModel extends ChangeNotifier {
  final AppContext _appContext;
  final ParticipantService _participantService;
  final BudgetService _budgetService;
  final Logger _logger = Logger("SettingsViewModel");

  SettingsViewModel(
    this._appContext,
    this._participantService,
    this._budgetService,
  );

  // ========== Current User State ==========

  models.Participant? get currentUser => _appContext.currentParticipant;

  bool get isManager => currentUser?.role == models.Role.manager;

  bool get isSignedIn => _appContext.isSignedIn;

  // ========== Settings Sections State ==========

  SettingsSection _currentSection = SettingsSection.profile;
  SettingsSection get currentSection => _currentSection;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ========== Initialization ==========

  /// Initialize the settings view
  /// Call this when entering the settings page
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Verify user is still signed in
      if (!_appContext.hasValidSession) {
        _setError('Session expired. Please sign in again.');
        _setLoading(false);
        return;
      }

      _clearError();
      _logger.info('Settings initialized for user: ${currentUser?.email}');
    } catch (e) {
      _logger.severe('Failed to initialize settings', e);
      _setError('Failed to initialize settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== Navigation ==========

  /// Switch to a different settings section
  void navigateToSection(SettingsSection section) {
    _currentSection = section;
    _clearError();
    notifyListeners();
  }

  /// Check if user has permission to access a section
  bool canAccessSection(SettingsSection section) {
    switch (section) {
      case SettingsSection.profile:
      case SettingsSection.myTemplates:
      case SettingsSection.myCategories:
      case SettingsSection.myAccounts:
      case SettingsSection.vendors:
        return true; // All users can access these

      case SettingsSection.allParticipants:
      case SettingsSection.allTemplates:
      case SettingsSection.allCategories:
      case SettingsSection.allAccounts:
        return isManager; // Only managers can access these
    }
  }

  // ========== Profile Actions ==========

  /// Get display name for current user
  String? get currentUserDisplayName =>
      _appContext.currentParticipantDisplayName;

  /// Get full name for current user
  String? get currentUserFullName {
    if (currentUser == null) return null;
    return '${currentUser!.firstName} ${currentUser!.lastName ?? ''}'.trim();
  }

  // ========== Sign Out ==========

  /// Sign out the current user and clear context
  /// Returns true if successful
  Future<bool> signOut() async {
    _setLoading(true);
    try {
      await _appContext.signOut();
      _logger.info('User signed out successfully');
      return true;
    } catch (e) {
      _logger.severe('Error signing out', e);
      _setError('Failed to sign out: $e');
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

  /// Helper to format participant display name
  String getParticipantDisplayName(models.Participant participant) {
    if (participant.nickname != null && participant.nickname!.isNotEmpty) {
      return participant.nickname!;
    }
    return participant.firstName;
  }

  /// Helper to format participant full name
  String getParticipantFullName(models.Participant participant) {
    final parts = [
      participant.firstName,
      if (participant.lastName != null) participant.lastName!,
    ];
    return parts.join(' ');
  }
}

/// Enum for different settings sections
enum SettingsSection {
  profile, // Current user's profile management
  allParticipants, // All participants (manager only)
  myTemplates, // Templates user is part of
  allTemplates, // All templates (manager only)
  myCategories, // Categories in user's templates
  allCategories, // All categories (manager only)
  myAccounts, // Accounts user is responsible for
  allAccounts, // All accounts (manager only)
  vendors, // Vendor-account associations
}
