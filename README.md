# tutorial_overlay

tutorial_overlay is a Flutter package for building interactive, step-by-step tutorials that highlight and point to widgets across multiple screens with customizable indicators.

## ✨ Features
- Step-by-Step Guidance: Highlight widgets and walk users through your app.
- Custom Tooltips: Add any widget (text, buttons, images, etc.) to explain each step.
- Custom Indicators: Use arrows or icons to point users to the right spot.
- Multi-Page Support: Keep the tutorial flowing across different screens.
- Dynamic Updates: Modify tutorials on-the-fly, e.g., for language changes.

## 📸 Screenshots

Here are some examples showcasing the features of `tutorial_overlay`:

<table>
  <tr>
    <th>
      Tutorial Across Pages
    </th>
    <th>
      Dynamic Updates
    </th>
    <th>
      Custom Indicator
    </th>
    <th>
      Tutorial without Target Widget
    </th>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/screenshots/tutorial-across-pages.gif" width="200"/> <br/>
      <em>Steps across multiple pages.</em>
    </td>
    <td align="center">
      <img src="assets/screenshots/tutorial-update.gif" width="200"/> <br/>
      <em>E.g. Updates on language change.</em>
    </td>
    <td align="center">
      <img src="assets/screenshots/custom-indicator.png" width="200"/>
      <em>Uses a custom arrow to highlight a widget.</em>
    </td>
    <td align="center">
      <img src="assets/screenshots/tutorial-without-target-widget.png" width="200"/>
      <em>Displays instructions without highlighting a widget.</em>
    </td>
  </tr>
</table>



## 🚀 Getting started

### Installation
Add `tutorial_overlay` to your `pubspec.yaml`:
```yaml
dependencies:
    tutorial_overlay: ^<latest_version>
```

Run the following command to fetch the package:
```bash
flutter pub get
```

Check the [pub.dev page](https://pub.dev/packages/tutorial_overlay) for the latest version.

### Example
To explore a working example, clone the repository and run the demo:
```bash
git clone https://github.com/xinyi-chong/tutorial_overlay.git
cd tutorial_overlay/example
flutter run
```

## 🛠 Usage
Follow these steps to integrate tutorial_overlay into your Flutter app.

**1. Mark Widgets with GlobalKey**

Assign a `GlobalKey` to any widget you want to highlight during the tutorial (e.g., a `Text` widget). This key uniquely identifies the widget for the tutorial to target:

```dart
final widgetToHighLightKey = GlobalKey();

Text(
    key: widgetToHighlightKey,
    'This text will be highlighted in the tutorial',
)
```

**2. Define Tutorial Steps and Provide Tutorial**

Create a `Tutorial` instance to define steps for each tutorial. The `tutorialId` (e.g., `'home'`) is a unique identifier for each tutorial, allowing you to create multiple tutorials for different parts of your app (e.g., `'home'` for onboarding, `'profile'` for user profile setup). Wrap your app with the tutorial provider to enable tutorial functionality:

```dart
void main() {
  final tutorial = Tutorial<String>({
    'home': [ // Tutorial for the home screen
      TutorialStep(
        widgetKey: widgetToHighlightKey, // Highlights a specific widget
        child: Column(
          children: [
            const Text('Welcome to the app! This highlights a key feature.'),
            ElevatedButton(
              onPressed: () => tutorial.nextStep('home'),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
      TutorialStep( // No widgetKey: shows general instructions
        child: Column(
          children: [
            const Text('The tutorial has ended.'),
            ElevatedButton(
              onPressed: () => tutorial.endTutorial('home'),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ],
    'profile': [ // Tutorial for the profile screen
      TutorialStep(
        widgetKey: profileButtonKey,
        child: const Text('Learn how to set up your profile here.'),
      ),
    ],
  });

  runApp(tutorial.provide(const MyApp()));
}
```

**3. Wrap Pages with TutorialOverlay**

Wrap each page with `TutorialOverlay` and specify the `tutorialId` that matches the tutorial defined in the `Tutorial` instance:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TutorialOverlay<String>(
        tutorialId: 'home',  // Matches the key in the tutorial map
        child: const MyHomePage(),
      ),
    );
  }
}
```

**4. Control the Tutorial**

Use these methods to manage the tutorial flow:

```dart
tutorial.startTutorial('home');
tutorial.nextStep('home');
tutorial.previousStep('home');
tutorial.endTutorial('home');
```

**5. Handle Navigation**

To navigate between pages during the tutorial:

```dart
// Navigate to a new route
tutorial.nextStep('home', route: '/your-page', context: context);
// Go back to the previous page
tutorial.previousStep('home', backToPreviousPage: true, context: context);
```


**6. Update Tutorials Dynamically**

Modify tutorials after initialization, e.g., for language changes:

```dart
// Define a function to build or update tutorials
Map<String, List<TutorialStep>> buildTutorials(String language) {
  return {
    'home': [
      TutorialStep(
        child: Column(
          children: [
            Text(language == 'en' ? 'Welcome to the app!' : '欢迎使用我们的应用！'),
            ElevatedButton(
              onPressed: () => tutorial.endTutorial('home'),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ],
  };
}

// Initialize and update the tutorial
void main() {
  final tutorial = Tutorial<String>(buildTutorials('en')); // Initial tutorial in English
  runApp(tutorial.provide(const MyApp()));

  // Example: Update tutorial for Chinese
  tutorial.updateTutorial(buildTutorials('zh'));
}
```

# 📋 Additional Notes
- Ensure `GlobalKey` is unique for each widget to avoid conflicts.
- Use `context` for navigation to ensure proper routing in multi-page tutorials.
- Customize indicators and tooltips by passing widgets to `TutorialStep`.
- Use distinct `tutorialId` values (e.g., `'home'`, `'profile'`) to manage multiple tutorials within the same app.
  
For more details, refer to the example folder in the repository.
