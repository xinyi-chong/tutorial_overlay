import 'package:example/translations.dart';
import 'package:example/tutorial_steps.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_overlay/tutorial_overlay.dart';

void main() {
  runApp(Tutorial.provide(tutorial: tutorial, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial Overlay Demo',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      routes: {
        '/':
            (context) => TutorialOverlay<TutorialID>(
              tutorialId: TutorialID.home,
              width: 300,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: MyHomePage(title: 'Home Page'),
            ),
        '/settings':
            (context) => TutorialOverlay<TutorialID>(
              tutorialId: TutorialID.settings,
              width: 300,
              dismissOnTap: false,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
              ),
              focusOverlayPadding: EdgeInsets.all(20),
              indicator: Column(
                children: [
                  Expanded(
                    child: Container(color: Colors.deepPurpleAccent, width: 2),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigoAccent,
                    ),
                  ),
                ],
              ),
              indicatorHeight: 50,
              indicatorWidth: 10,
              child: SettingPage(),
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Text(widget.title),
            IconButton(
              key: helpButtonKey,
              onPressed: () => tutorial.startTutorial(TutorialID.home),
              icon: Icon(Icons.help),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentLang = currentLang == "en" ? "zh" : "en";
                });
                tutorial.updateTutorial(buildTutorials());
              },
              child: Text(currentLang),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              key: settingsButtonKey,
              onPressed: () => Navigator.pushNamed(context, "/settings"),
              icon: Icon(Icons.settings),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "The number below updates each time you press the '+' button.",
              ),
              Text(
                key: counterTextKey,
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: counterButtonKey,
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
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
        title: Row(
          children: [
            Text("Setting Page"),
            IconButton(
              onPressed: () => tutorial.startTutorial(TutorialID.settings),
              icon: Icon(Icons.help),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Setting Page'),
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
