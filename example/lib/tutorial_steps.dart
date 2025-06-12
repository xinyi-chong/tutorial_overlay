import 'package:example/translations.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_overlay/tutorial_overlay.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global keys for tutorial targets
final GlobalKey counterTextKey = GlobalKey();
final GlobalKey counterButtonKey = GlobalKey();
final GlobalKey backButtonKey = GlobalKey();
final GlobalKey helpButtonKey = GlobalKey();
final GlobalKey settingsButtonKey = GlobalKey();

enum TutorialID { home, settings }

final tutorial = Tutorial<TutorialID>(buildTutorials());

Map<TutorialID, List<TutorialStep>> buildTutorials() {
  return {
    TutorialID.home: [
      TutorialStep(
        widgetKey: counterTextKey,
        child: _tutorialCard(
          text: t("counterText"),
          buttons: [_nextButton(TutorialID.home)],
        ),
      ),
      TutorialStep(
        widgetKey: counterButtonKey,
        child: _tutorialCard(
          text: t("counterButton"),
          buttons: [_backButton(TutorialID.home), _nextButton(TutorialID.home)],
        ),
      ),
      TutorialStep(
        widgetKey: settingsButtonKey,
        child: _tutorialCard(
          text: t("settingsButton"),
          buttons: [
            _backButton(TutorialID.home),
            _nextButton(TutorialID.home, route: "/settings"),
          ],
        ),
      ),
      TutorialStep(
        widgetKey: backButtonKey,
        child: _tutorialCard(
          text: t("backButton"),
          buttons: [
            _backButton(TutorialID.home, backToPreviousPage: true),
            _nextButton(TutorialID.home, backToPreviousPage: true),
          ],
        ),
      ),
      TutorialStep(
        widgetKey: helpButtonKey,
        child: _tutorialCard(
          text: t("helpButton"),
          buttons: [
            _backButton(TutorialID.home, route: "/settings"),
            _doneButton(TutorialID.home),
          ],
        ),
      ),
    ],
    TutorialID.settings: [
      TutorialStep(
        showAbove: false,
        widgetKey: backButtonKey,
        child: _tutorialCard(
          text: t("goBackSettings"),
          buttons: [_doneButton(TutorialID.settings)],
        ),
      ),
    ],
  };
}

Widget _tutorialCard({required String text, required List<Widget> buttons}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(text), SizedBox(height: 10), Row(children: buttons)],
  );
}

Widget _nextButton(
  TutorialID tutorialId, {
  String? route,
  bool backToPreviousPage = false,
}) {
  return Expanded(
    child: ElevatedButton(
      onPressed: () {
        tutorial.nextStep(
          tutorialId: tutorialId,
          route: route,
          backToPreviousPage: backToPreviousPage,
          context: navigatorKey.currentContext,
        );
      },
      child: const Text("Next"),
    ),
  );
}

Widget _backButton(
  TutorialID tutorialId, {
  String? route,
  bool backToPreviousPage = false,
}) {
  return Expanded(
    child: ElevatedButton(
      onPressed: () {
        tutorial.previousStep(
          tutorialId: tutorialId,
          route: route,
          backToPreviousPage: backToPreviousPage,
          context: navigatorKey.currentContext,
        );
      },
      child: const Text("Back"),
    ),
  );
}

Widget _doneButton(TutorialID tutorialId) {
  return Expanded(
    child: ElevatedButton(
      onPressed: () => tutorial.endTutorial(tutorialId),
      child: const Text("Done"),
    ),
  );
}
