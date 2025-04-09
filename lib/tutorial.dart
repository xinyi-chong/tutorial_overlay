import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_overlay/src/tutorial_state.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

/// A controller for managing tutorial steps and state in a Flutter app.
class Tutorial<T> {
  final Map<T, List<TutorialStep>> _tutorials;
  final TutorialState _state;

  Tutorial(this._tutorials) : _state = TutorialState(_tutorials);

  /// Starts the tutorial with the given [tutorialId].
  void startTutorial(T tutorialId) {
    if (!_tutorials.containsKey(tutorialId)) {
      throw Exception('Tutorial ID "$tutorialId" not found');
    }
    _state.startTutorial(tutorialId);
  }

  /// Advances to the next step in the tutorial.
  /// If [route] is provided, navigates to that route.
  /// If [backToPreviousPage] is true, pops the current page.
  void nextStep(
    T tutorialId, {
    String? route,
    bool backToPreviousPage = false,
    BuildContext? context,
  }) {
    if (!_tutorials.containsKey(tutorialId)) {
      throw Exception('Tutorial ID "$tutorialId" not found');
    }
    _state.nextStep(tutorialId);
    if (route != null && context != null) {
      Navigator.pushNamed(context, route);
    } else if (backToPreviousPage && context != null) {
      Navigator.pop(context);
    }
  }

  /// Goes back to the previous step in the tutorial.
  /// If [route] is provided, navigates to that route.
  /// If [backToPreviousPage] is true, pops the current page.
  void previousStep(
    T tutorialId, {
    String? route,
    bool backToPreviousPage = false,
    BuildContext? context,
  }) {
    if (!_tutorials.containsKey(tutorialId)) {
      throw Exception('Tutorial ID "$tutorialId" not found');
    }
    _state.previousStep(tutorialId);
    if (route != null && context != null) {
      Navigator.pushNamed(context, route);
    } else if (backToPreviousPage && context != null) {
      Navigator.pop(context);
    }
  }

  /// Ends the tutorial with the given [tutorialId].
  void endTutorial(T tutorialId) {
    _state.endTutorial(tutorialId);
  }

  /// Wraps the app with a [ChangeNotifierProvider] to provide the tutorial state.
  Widget provide(Widget child) {
    return ChangeNotifierProvider.value(value: _state, child: child);
  }
}