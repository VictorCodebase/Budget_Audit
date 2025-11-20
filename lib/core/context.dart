import 'package:budget_audit/core/models/json_serialization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/models/models.dart';

/// Persistent app context that stores user session and template state
/// Uses SharedPreferences for persistence across app restarts
class AppContext extends ChangeNotifier {
  static const String _keyCurrentParticipant = 'current_participant';
  static const String _keyCurrentTemplate = 'current_template';
  static const String _keyIsSignedIn = 'is_signed_in';

  SharedPreferences? _prefs;

  Participant? _currentParticipant;
  Template? _currentTemplate;
  bool _isSignedIn = false;
  bool _isInitialized = false;

  Participant? get currentParticipant => _currentParticipant;
  Template? get currentTemplate => _currentTemplate;
  bool get isSignedIn => _isSignedIn;
  bool get isInitialized => _isInitialized;

  /// Initialize the context by loading persisted data
  /// Call this once at app startup before using the context
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadPersistedData();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize AppContext: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Load all persisted data from SharedPreferences
  Future<void> _loadPersistedData() async {
    if (_prefs == null) return;

    // Load signed-in state
    _isSignedIn = _prefs!.getBool(_keyIsSignedIn) ?? false;

    // Load current participant
    final participantJson = _prefs!.getString(_keyCurrentParticipant);
    if (participantJson != null) {
      try {
        final participantMap = jsonDecode(participantJson) as Map<String, dynamic>;
        _currentParticipant = ParticipantJson.fromJson(participantMap);
      } catch (e) {
        debugPrint('Failed to load participant: $e');
        _currentParticipant = null;
      }
    }

    // Load current template
    final templateJson = _prefs!.getString(_keyCurrentTemplate);
    if (templateJson != null) {
      try {
        final templateMap = jsonDecode(templateJson) as Map<String, dynamic>;
        _currentTemplate = TemplateJson.fromJson(templateMap);
      } catch (e) {
        debugPrint('Failed to load template: $e');
        print("The template in question: $templateJson");
        _currentTemplate = null;
      }
    }
  }

  /// Set the current participant and persist to storage
  Future<void> setParticipant(Participant participant) async {
    _currentParticipant = participant;
    _isSignedIn = true;

    if (_prefs != null) {
      try {
        final participantJson = jsonEncode(participant.toJson());
        await _prefs!.setString(_keyCurrentParticipant, participantJson);
        await _prefs!.setBool(_keyIsSignedIn, true);
        print("set participant: ${participant.firstName}");
      } catch (e) {
        debugPrint('Failed to persist participant: $e');
      }
    }

    notifyListeners();
  }

  /// Set the current template and persist to storage
  Future<void> setCurrentTemplate(Template template) async {
    _currentTemplate = template;

    if (_prefs != null) {
      try {
        final templateJson = jsonEncode(template.toJson());
        await _prefs!.setString(_keyCurrentTemplate, templateJson);
        print("set template: ${template.templateName}");
      } catch (e) {
        debugPrint('Failed to persist template: $e');
      }
    }

    notifyListeners();
  }

  /// Clear the current template and remove from storage
  Future<void> clearCurrentTemplate() async {
    _currentTemplate = null;

    if (_prefs != null) {
      await _prefs!.remove(_keyCurrentTemplate);
    }

    notifyListeners();
  }

  /// Sign out the current user and clear all persisted data
  Future<void> signOut() async {
    _currentParticipant = null;
    _currentTemplate = null;
    _isSignedIn = false;

    if (_prefs != null) {
      await _prefs!.remove(_keyCurrentParticipant);
      await _prefs!.remove(_keyCurrentTemplate);
      await _prefs!.setBool(_keyIsSignedIn, false);
    }

    notifyListeners();
  }

  /// Clear all context data (for debugging or reset)
  Future<void> clear() async {
    await signOut();
  }

  /// Check if a participant is currently signed in with valid data
  bool get hasValidSession {
    print("Session valid");
    return _isSignedIn && _currentParticipant != null;
  }

  /// Get a display name for the current participant
  String? get currentParticipantDisplayName {
    if (_currentParticipant == null) return null;

    if (_currentParticipant!.nickname != null &&
        _currentParticipant!.nickname!.isNotEmpty) {
      return _currentParticipant!.nickname;
    }
    return _currentParticipant!.firstName;
  }
}