import 'package:flutter/material.dart';
import '../../core/models/models.dart';

class AppContext extends ChangeNotifier {
  Participant? _currentParticipant;
  Template? _currentTemplate;

  Participant? get currentParticipant => _currentParticipant;
  Template? get currentTemplate => _currentTemplate;

  void setParticipant(Participant participant) {
    _currentParticipant = participant;
    notifyListeners();
  }

  void setCurrentTemplate(Template template) {
    _currentTemplate = template;
    notifyListeners();
  }

  void clearCurrentTemplate() {
    _currentTemplate = null;
    notifyListeners();
  }

  void clear() {
    _currentParticipant = null;
    _currentTemplate = null;
    notifyListeners();
  }
}