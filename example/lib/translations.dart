String currentLang = 'en';

final translations = {
  'en': {
    'counterText':
        "The number below updates each time you press the '+' button.",
    'counterButton': "Tap this button to increment the counter.",
    'settingsButton':
        "Tap the settings icon to navigate to the Settings screen.",
    'backButton': "Tap this button to return to the Home screen.",
    'helpButton': "Tap the help icon to view this tutorial again at any time.",
    'goBackSettings': "Click the Go Back button to return to the Home page.",
  },
  'zh': {
    'counterText': "每次按下 '+' 按钮，下方的数字都会更新。",
    'counterButton': "点击此按钮以增加计数。",
    'settingsButton': "点击设置图标进入设置页面。",
    'backButton': "点击此按钮返回主页面。",
    'helpButton': "点击帮助图标可再次查看此教程。",
    'goBackSettings': "点击返回按钮回到主页面。",
  },
};

String t(String key) => translations[currentLang]![key]!;
