App.accessRule('*');

App.info({
  id: 'com.retronator.pixelartacademy-learnmode',
  name: 'Pixel Art Academy Learn Mode',
  description: 'The best app for learning pixel art',
  author: 'Matej Jan, Retronator',
  email: 'hi@retronator.com',
  website: 'https://pixelart.academy'
});

App.icons({
  'app_store': '.cordova/assets/icons/app_store.png'
});

App.setPreference('BackgroundColor', '0xff000000');
App.setPreference('Orientation', 'landscape');
App.setPreference('Fullscreen', 'true');
