
import 'package:flutter/material.dart';
import '../../core/models/models.dart';

class AppContext extends ChangeNotifier {
  Participant? _currentParticipant;
  bool? _onboardComplete;

  Participant? get currentParticipant => _currentParticipant;
  bool? get onboardComplete => _onboardComplete;

  void setParticipant(Participant participant) {
    _currentParticipant = participant;
    notifyListeners();
  }

  void setOnboardStatus(bool onboardStatus){
    _onboardComplete = onboardComplete;
    notifyListeners();
  }

  void clear() {
    _currentParticipant = null;
    _onboardComplete = false;
    notifyListeners();
  }
}
