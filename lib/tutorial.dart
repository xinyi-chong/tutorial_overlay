import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

/// A controller for managing tutorial state and navigation.
///
/// The [Tutorial] class handles the state of multiple tutorials, each identified
/// by a unique [T] type ID (e.g., String for 'home', 'profile'). It tracks the
/// current step, manages navigation across screens, and notifies listeners to
/// update the UI. Use with [TutorialOverlay] to display tooltips and highlight
/// widgets during tutorials.
class Tutorial<T> extends ChangeNotifier {
  Map<T, List<TutorialStep>> _tutorials;
  final Map<T, int> _currentSteps = {};
  final NavigatorState? _customNavigator;

  /// Creates a tutorial controller with the given tutorials.
  ///
  /// Parameters:
  /// - [tutorials]: A map of tutorial IDs to their respective [TutorialStep] lists.
  /// - [navigator]: Optional [NavigatorState] for custom navigation control.
  ///
  /// Example:
  /// ```dart
  /// final tutorial = Tutorial<String>({
  ///   'home': [TutorialStep(child: Text('Step 1'))],
  /// });
  /// ```
  Tutorial(Map<T, List<TutorialStep>> tutorials, {NavigatorState? navigator})
    : _tutorials = Map.from(tutorials),
      _customNavigator = navigator {
    initializeState();
  }

  /// Returns a list of all available tutorial IDs.
  List<T> get availableTutorials => _tutorials.keys.toList();

  /// Returns the current step index for the specified [tutorialId].
  ///
  /// Returns -1 if the tutorial has not started, 0 for the first step, etc.
  int getCurrentStep(T tutorialId) => _currentSteps[tutorialId] ??= -1;

  /// Returns the list of steps for the specified [tutorialId].
  ///
  /// Returns an empty list if the [tutorialId] is not found.
  List<TutorialStep> getSteps(T tutorialId) => _tutorials[tutorialId] ?? [];

  /// Checks if the current step is the last one for the specified [tutorialId].
  bool isLastStep(T tutorialId) {
    final steps = getSteps(tutorialId);
    return steps.isNotEmpty && _currentSteps[tutorialId] == steps.length - 1;
  }

  /// Updates the tutorials with a new map of tutorial steps.
  ///
  /// Useful for dynamic updates, such as changing languages.
  ///
  /// Example:
  /// ```dart
  /// tutorial.updateTutorial({'home': [TutorialStep(child: Text('New Step')]});
  /// ```
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
  ///
  /// If the current step is the last one, ends the tutorial. Optionally navigates
  /// to a [route] or pops the current page if [backToPreviousPage] is true.
  /// Notifies listeners to update the UI.
  ///
  /// Parameters:
  /// - [tutorialId]: The ID of the tutorial to advance.
  /// - [route]: Optional route to navigate to.
  /// - [arguments]: Optional arguments for the route.
  /// - [backToPreviousPage]: If true, pops the current page. Defaults to false.
  /// - [context]: The [BuildContext] for navigation. Required if [route] or
  ///   [backToPreviousPage] is used, unless [_customNavigator] is provided.
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
  ///
  /// If the current step is the first one (index 0), no action is taken.
  /// Optionally navigates to a [route] or pops the current page if
  /// [backToPreviousPage] is true. 
  ///
  /// Parameters:
  /// - [tutorialId]: The ID of the tutorial to navigate back in.
  /// - [route]: Optional route to navigate to.
  /// - [arguments]: Optional arguments for the route.
  /// - [backToPreviousPage]: If true, pops the current page. Defaults to false.
  /// - [context]: The [BuildContext] for navigation. Required if [route] or
  ///   [backToPreviousPage] is used, unless [_customNavigator] is provided.
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

  /// Validates that the given [tutorialId] exists in [_tutorials].
  ///
  /// Throws [TutorialNotFoundException] if the ID is invalid.
  void _validateTutorialId(T tutorialId) {
    if (!_tutorials.containsKey(tutorialId)) {
      throw TutorialNotFoundException(tutorialId);
    }
  }

  /// Handles navigation for tutorial steps.
  ///
  /// Pushes a new [route] with optional [arguments] or pops the current page if
  /// [back] is true. Uses [_customNavigator] if available, otherwise uses
  /// [Navigator.of(context)].
  ///
  /// Parameters:
  /// - [route]: The route to navigate to, if any.
  /// - [arguments]: Arguments to pass to the route.
  /// - [back]: If true, pops the current page.
  /// - [context]: The [BuildContext] for navigation, required if [_customNavigator] is null.
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
