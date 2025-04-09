import 'package:flutter/material.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

class TutorialState<T> extends ChangeNotifier {
  /// A map of tutorial IDs to their corresponding list of steps.
  final Map<T, List<TutorialStep>> _tutorials;

  /// A map that keeps track of the current step index for each tutorial.
  final Map<T, int> _currentSteps = {};

  TutorialState(this._tutorials) {
    for (var id in _tutorials.keys) {
      _currentSteps[id] = -1;
    }
  }

  int getCurrentStep(T tutorialId) => _currentSteps[tutorialId] ?? -1;

  List<TutorialStep>? getSteps(T tutorialId) => _tutorials[tutorialId];

  void startTutorial(T tutorialId) {
    if (_tutorials.containsKey(tutorialId)) {
      _currentSteps[tutorialId] = 0;
      notifyListeners();
    }
  }

  void nextStep(T tutorialId) {
    final steps = _tutorials[tutorialId];
    if (steps != null && _currentSteps[tutorialId]! < steps.length - 1) {
      _currentSteps[tutorialId] = _currentSteps[tutorialId]! + 1;
      notifyListeners();
    }
  }

  void previousStep(T tutorialId) {
    if (_currentSteps[tutorialId]! > 0) {
      _currentSteps[tutorialId] = _currentSteps[tutorialId]! - 1;
      notifyListeners();
    }
  }

  void endTutorial(T tutorialId) {
    if (_tutorials.containsKey(tutorialId)) {
      _currentSteps[tutorialId] = -1;
      notifyListeners();
    }
  }
}
