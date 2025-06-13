import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

/// A controller for managing tutorial state and navigation.
///
/// Handles multiple tutorials identified by type [T] (typically String enums).
/// Works with [TutorialOverlay] to display step-by-step guides with tooltips.
///
/// Example:
/// ```dart
/// final tutorial = Tutorial<String>({
///   'home': [TutorialStep(child: Text('Welcome!'))],
///   'checkout': [TutorialStep(child: Text('Complete your purchase'))],
/// });
/// ```
class Tutorial<T> extends ChangeNotifier {
  Map<T, List<TutorialStep>> _tutorials;
  final Map<T, int> _currentSteps = {};
  final NavigatorState? _customNavigator;

  /// Creates a tutorial controller with the given tutorials.
  ///
  /// Parameters:
  /// - [tutorials]: A map of tutorial IDs to their respective [TutorialStep] lists.
  /// - [navigator]: Optional [NavigatorState] for multi-screen tutorials.
  Tutorial(Map<T, List<TutorialStep>> tutorials, {NavigatorState? navigator})
    : _tutorials = Map.from(tutorials),
      _customNavigator = navigator {
    initializeState();
  }

  /// Returns a list of all available tutorial IDs.
  List<T> get availableTutorials => _tutorials.keys.toList();

  /// Gets current step index (-1 = not started)
  int getCurrentStep(T tutorialId) => _currentSteps[tutorialId] ??= -1;

  /// Gets all steps for a tutorial (empty if not found)
  List<TutorialStep> getSteps(T tutorialId) => _tutorials[tutorialId] ?? [];

  /// Whether current step is the last one
  bool isLastStep(T tutorialId) {
    final steps = getSteps(tutorialId);
    return steps.isNotEmpty && _currentSteps[tutorialId] == steps.length - 1;
  }

  /// Updates the tutorials with a new map of tutorial steps.
  ///
  /// Useful for dynamic updates, such as changing languages.
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

  /// Advances to the next step or ends tutorial if last step.
  ///
  /// Optional navigation:
  /// - [route]: Name of route to push
  /// - [arguments]: Route arguments
  /// - [backToPreviousPage]: Pop current route
  /// - [context]: Required for navigation if no custom navigator provided
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

  /// Returns to previous step (if not first step)
  ///
  /// Optional navigation:
  /// - [route]: Name of route to push
  /// - [arguments]: Route arguments
  /// - [backToPreviousPage]: Pop current route
  /// - [context]: Required for navigation if no custom navigator provided
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

  /// Wraps the widget tree with a [ChangeNotifierProvider] to provide the tutorial controller.
  ///
  /// This enables [TutorialOverlay] and other widgets to access the tutorial state.
  ///
  /// Parameters:
  /// - [tutorial]: The [Tutorial] instance to provide.
  /// - [child]: The widget tree to wrap.
  ///
  /// Example:
  /// ```dart
  /// Tutorial.provide(tutorial: tutorial, child: const MyApp());
  /// ```
  static Widget provide({required Tutorial tutorial, required Widget child}) {
    return ChangeNotifierProvider.value(value: tutorial, child: child);
  }

  /// Initializes the state for specified or all tutorials.
  ///
  /// Sets the step index to -1 (not started) for each tutorial ID.
  ///
  /// Parameters:
  /// - [tutorialIds]: Optional list of tutorial IDs to initialize. If null,
  ///   initializes all tutorials in [_tutorials].
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

/// Exception thrown when a tutorial ID is not found in the registered tutorials.
class TutorialNotFoundException implements Exception {
  final dynamic tutorialId;

  TutorialNotFoundException(this.tutorialId);

  @override
  String toString() => 'Tutorial "$tutorialId" not found';
}
