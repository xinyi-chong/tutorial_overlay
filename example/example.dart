/// For a full working example with multi-page tutorials, custom indicators, localization updates, and more:
/// 👉 See full example here: https://github.com/xinyi-chong/tutorial_overlay/blob/main/example/lib/

import 'package:flutter/material.dart';
import 'package:tutorial_overlay/tutorial_overlay.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey settingsButtonKey = GlobalKey();
final GlobalKey backButtonKey = GlobalKey();

final tutorial = Tutorial<String>(buildTutorials());

Map<String, List<TutorialStep>> buildTutorials() {
  return {
    "home": [
      TutorialStep(
        widgetKey: settingsButtonKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tap the settings icon to navigate to the Settings screen."),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                tutorial.nextStep(
                  'home',
                  route: '/settings',
                  context: navigatorKey.currentContext,
                );
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
      TutorialStep(
        widgetKey: backButtonKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tap this button to return to the Home screen."),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    tutorial.previousStep(
                      'home',
                      backToPreviousPage: true,
                      context: navigatorKey.currentContext,
                    );
                  },
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () {
                    tutorial.endTutorial('home');
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  };
}

void main() {
  runApp(tutorial.provide(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      routes: {
        '/':
            (context) => TutorialOverlay<String>(
          tutorialId: 'home',
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: MyHomePage(),
        ),
        '/settings': (context) => SettingPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Text('Flutter Demo Home Page'),
            IconButton(
              onPressed: () => tutorial.startTutorial('home'),
              icon: Icon(Icons.help),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              key: settingsButtonKey,
              onPressed: () => Navigator.pushNamed(context, "/settings"),
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Demo Setting Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Demo Setting Page'),
            ElevatedButton(
              key: backButtonKey,
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
