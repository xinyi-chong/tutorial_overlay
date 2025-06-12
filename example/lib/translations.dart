String currentLang = 'en';

final translations = {
  'en': {
    'welcomeTitle': 'This is the welcome title of the app.',
    'navigateButton': 'Click here to go to the Secondary page.',
    'secondaryPage': 'You’re now on the Secondary page.',
    'helpButton': 'Click here to start the Secondary page tutorial.',
    'returnButton': 'Click here to return to the Home page.',
    'languageToggle': 'Switch Language',
    'step': 'Step',
    'next': 'Next',
    'back': 'Back',
    'done': 'Done',
    'customIndicator': 'This step shows a custom indicator.',
    'dismissNote': 'Tapping outside won’t close this.',
    'noTargetWidget': 'This step has no highlighted widget.',
  },
  'zh': {
    'welcomeTitle': '这是应用程序的欢迎标题。',
    'navigateButton': '点击这里访问次要页面。',
    'secondaryPage': '您现在已导航到次要页面。',
    'helpButton': '点击这里启动次要页面教程。',
    'returnButton': '点击这里返回主页。',
    'languageToggle': '切换语言',
    'step': '步骤',
    'next': '下一步',
    'back': '返回',
    'done': '完成',
    'customIndicator': '此步骤展示自定义指示器。',
    'dismissNote': '点击外部不会关闭此教程。',
    'noTargetWidget': '此步骤不突出任何控件。',
  },
};

String t(String key) => translations[currentLang]![key]!;
