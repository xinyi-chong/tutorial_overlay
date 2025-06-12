import 'package:example/translations.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_overlay/tutorial_overlay.dart';

// Initialize with navigator key (required for navigation between steps)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global keys for tutorial target widgets
final GlobalKey navigateButtonKey = GlobalKey();
final GlobalKey returnButtonKey = GlobalKey();
final GlobalKey helpButtonKey = GlobalKey();

enum TutorialID { home, secondary } // Unique identifiers for each tutorial

// Tutorial instance with predefined steps
final tutorial = Tutorial<TutorialID>(buildTutorials());

void main() {
  // Wrap your app with the tutorial provider
  runApp(Tutorial.provide(tutorial: tutorial, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial Overlay Demo',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/':
            (context) => TutorialOverlay<TutorialID>(
              tutorialId: TutorialID.home,
              width: 320, // Set overlay width
              // Default styling for all tutorial steps with this tutorialId
              padding: const EdgeInsets.all(16), // Padding around content
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              focusOverlayPadding: const EdgeInsets.all(
                12,
              ), // Padding around highlighted widget
              indicator: Column(
                children: [
                  Expanded(
                    child: Container(color: Colors.greenAccent, width: 5),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              indicatorHeight: 50,
              indicatorWidth: 10,
              child: const HomePage(),
            ),
        '/secondary':
            (context) => TutorialOverlay<TutorialID>(
              tutorialId: TutorialID.secondary,
              width: 320,
              dismissOnTap: false, // prevent dismiss when tapping outside
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SecondaryPage(),
            ),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => tutorial.startTutorial(TutorialID.home),
              child: const Text(
                'Click me to start tutorial!',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              key: navigateButtonKey, // Target for tutorial step
              onPressed: () => Navigator.pushNamed(context, '/secondary'),
              child: const Text('Go to Secondary Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryPage extends StatelessWidget {
  const SecondaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secondary Page'),
        actions: [
          IconButton(
            key: helpButtonKey,
            icon: const Icon(Icons.help_outline),
            onPressed:
                () => tutorial.startTutorial(
                  TutorialID.secondary,
                ), // Start tutorial
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          key: returnButtonKey, // Target for tutorial step
          onPressed: () => Navigator.pop(context),
          child: const Text('Return to Welcome'),
        ),
      ),
    );
  }
}

// Define tutorial steps for each tutorial ID
Map<TutorialID, List<TutorialStep>> buildTutorials({bool isStyled = false}) {
  return {
    // Home page tutorial
    TutorialID.home: [
      TutorialStep(
        widgetKey: navigateButtonKey,
        child: _tutorialCard(
          step: 1,
          text: t("navigateButton"),
          buttons: [
            _backButton(TutorialID.home),
            _nextButton(TutorialID.home, route: '/secondary'),
          ],
        ),
      ),
      TutorialStep(
        // No widgetKey: shows general instruction
        child: _tutorialCard(
          step: 2,
          text: "${t("secondaryPage")} (${t("noTargetWidget")})",
          buttons: [
            _backButton(TutorialID.home, backToPreviousPage: true),
            _nextButton(TutorialID.home),
          ],
        ),
      ),
      TutorialStep(
        widgetKey: helpButtonKey,
        // Custom indicator for this step
        indicator: Container(color: Colors.lightBlue),
        indicatorWidth: 5,
        child: _tutorialCard(
          step: 3,
          text: "${t("helpButton")} (${t("customIndicator")})",
          buttons: [_backButton(TutorialID.home), _doneButton(TutorialID.home)],
        ),
      ),
    ],
    // Secondary page tutorial
    TutorialID.secondary: [
      TutorialStep(
        widgetKey: returnButtonKey,
        child: _tutorialCard(
          text: "${t("returnButton")} (${t("dismissNote")})",
          buttons: [_doneButton(TutorialID.secondary)],
        ),
      ),
    ],
  };
}

// Helper widget for tutorial step content
Widget _tutorialCard({
  int? step,
  required String text,
  required List<Widget> buttons,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (step != null) Expanded(child: Text("${t("step")} $step")),
            TextButton(
              onPressed: () {
                currentLang = currentLang == "en" ? "zh" : "en";
                tutorial.updateTutorial(buildTutorials());
              },
              child: Text(
                t("languageToggle"),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        Text(text, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons),
      ],
    ),
  );
}

// Next button for advancing tutorial steps
Widget _nextButton(
  TutorialID tutorialId, {
  String? route,
  bool backToPreviousPage = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8),
    child: ElevatedButton(
      onPressed: () {
        tutorial.nextStep(
          tutorialId: tutorialId,
          context: navigatorKey.currentContext,
          route: route,
          backToPreviousPage: backToPreviousPage,
        );
      },
      child: Text(t('next')),
    ),
  );
}

// Back button for returning to previous tutorial steps
Widget _backButton(
  TutorialID tutorialId, {
  String? route,
  bool backToPreviousPage = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: OutlinedButton(
      onPressed: () {
        tutorial.previousStep(
          tutorialId: tutorialId,
          context: navigatorKey.currentContext,
          route: route,
          backToPreviousPage: backToPreviousPage,
        );
      },
      child: Text(t('back')),
    ),
  );
}

// Done button to end the tutorial
Widget _doneButton(TutorialID tutorialId) {
  return ElevatedButton(
    onPressed: () => tutorial.endTutorial(tutorialId),
    child: Text(t('done')),
  );
}
