import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

/// A tutorial controller that manages both state and navigation
class Tutorial<T> extends ChangeNotifier {
  Map<T, List<TutorialStep>> _tutorials;
  final Map<T, int> _currentSteps = {};
  final NavigatorState? _customNavigator;

  /// Creates a tutorial controller
  Tutorial(Map<T, List<TutorialStep>> tutorials, {NavigatorState? navigator})
    : _tutorials = Map.from(tutorials),
      _customNavigator = navigator {
    initializeState();
  }

  /// All available tutorial IDs
  List<T> get availableTutorials => _tutorials.keys.toList();

  /// Current step index (-1 means not started, 0 is first step)
  int getCurrentStep(T tutorialId) => _currentSteps[tutorialId] ??= -1;

  /// All steps for a tutorial
  List<TutorialStep> getSteps(T tutorialId) => _tutorials[tutorialId] ?? [];

  /// Checks if current step is the last one
  bool isLastStep(T tutorialId) {
    final steps = getSteps(tutorialId);
    return steps.isNotEmpty && _currentSteps[tutorialId] == steps.length - 1;
  }

  void updateTutorial(Map<T, List<TutorialStep>> newTutorials) {
    _tutorials = Map.from(newTutorials);
    notifyListeners();
  }

  /// Starts the tutorial with the given [tutorialId].
  void startTutorial(T tutorialId) {
    _validateTutorialId(tutorialId);
    _currentSteps[tutorialId] = 0;
    notifyListeners();
  }

  /// Advances to the next step in the tutorial.
  /// If [route] is provided, navigates to that route.
  /// If [backToPreviousPage] is true, pops the current page.
  void nextStep({
    required T tutorialId,
    String? route,
    Object? arguments,
    bool backToPreviousPage = false,
    BuildContext? context,
  }) {
    _validateTutorialId(tutorialId);

    if (isLastStep(tutorialId)) {
      endTutorial(tutorialId);
    } else {
      _currentSteps[tutorialId] = getCurrentStep(tutorialId) + 1;
    }

    _handleNavigation(
      route: route,
      arguments: arguments,
      back: backToPreviousPage,
      context: context,
    );
    notifyListeners();
  }

  /// Goes back to the previous step in the tutorial.
  /// If [route] is provided, navigates to that route.
  /// If [backToPreviousPage] is true, pops the current page.
  void previousStep({
    required T tutorialId,
    String? route,
    Object? arguments,
    bool backToPreviousPage = false,
    BuildContext? context,
  }) {
    _validateTutorialId(tutorialId);

    final current = getCurrentStep(tutorialId);
    if (current > 0) {
      _currentSteps[tutorialId] = current - 1;
      _handleNavigation(
        route: route,
        arguments: arguments,
        back: backToPreviousPage,
        context: context,
      );
      notifyListeners();
    }
  }

  /// Ends the tutorial with the given [tutorialId].
  void endTutorial(T tutorialId) {
    _validateTutorialId(tutorialId);
    _currentSteps[tutorialId] = -1;
    notifyListeners();
  }

  /// Wraps the widget tree with tutorial provider
  ///
  /// Usage:
  /// ```dart
  /// return Tutorial.provide(
  ///   tutorial: tutorial,
  ///   child: MyApp(),
  /// );
  /// ```
  static Widget provide({required Tutorial tutorial, required Widget child}) {
    return ChangeNotifierProvider.value(value: tutorial, child: child);
  }

  /// Initializes tutorial states
  ///
  /// Parameters:
  /// - `tutorialIds`: Specific tutorials to initialize (null for all)
  ///
  /// Sets all specified tutorials to "not started" state (-1)
  void initializeState({List<T>? tutorialIds}) {
    final idsToInitialize =
        tutorialIds == null ? _tutorials.keys.toList() : tutorialIds;
    for (final id in idsToInitialize) {
      _currentSteps[id] = -1;
    }
    notifyListeners();
  }

  void _validateTutorialId(T tutorialId) {
    if (!_tutorials.containsKey(tutorialId)) {
      throw TutorialNotFoundException(tutorialId);
    }
  }

  void _handleNavigation({
    String? route,
    Object? arguments,
    bool back = false,
    BuildContext? context,
  }) {
    if (context == null && _customNavigator == null) return;

    final navigator = _customNavigator ?? Navigator.of(context!);

    if (route != null) {
      navigator.pushNamed(route, arguments: arguments);
    } else if (back) {
      navigator.pop();
    }
  }
}

class TutorialNotFoundException implements Exception {
  final dynamic tutorialId;

  TutorialNotFoundException(this.tutorialId);

  @override
  String toString() => 'Tutorial "$tutorialId" not found';
}
