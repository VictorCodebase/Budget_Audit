
import 'package:flutter/material.dart';
import '../../core/models/models.dart';

class AppContext extends ChangeNotifier {
  Participant? _currentParticipant;

  Participant? get currentParticipant => _currentParticipant;

  void setParticipant(Participant participant) {
    _currentParticipant = participant;
    notifyListeners();
  }

  void clear() {
    _currentParticipant = null;
    notifyListeners();
  }
}
