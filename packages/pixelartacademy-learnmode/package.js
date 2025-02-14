Package.describe({
  name: 'retronator:pixelartacademy-learnmode',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-pixelpad-notifications');

  api.export('PixelArtAcademy');

  api.addFile('learnmode');
  api.addFile('region');
  api.addClientFile('spacebars');

  api.addFile('adventure..');
  api.addFile('chapter..');

  api.addComponent('interface..');
  api.addFile('interface/interface-music');
  api.addComponent('interface/studio..');

  api.addFile('content..');
  api.addFile('content/goalcontent');
  api.addFile('content/appcontent');
  api.addFile('content/drawingtutorialcontent');
  api.addFile('content/futurecontent');
  api.addFile('content/course');
  api.addFile('content/tags');

  api.addFile('content/progress..');
  api.addFile('content/progress/manualprogress');
  api.addFile('content/progress/unitprogress');
  api.addFile('content/progress/contentprogress');
  api.addFile('content/progress/goalprogress');
  api.addFile('content/progress/taskprogress');
  api.addFile('content/progress/projectassetprogress');
  api.addFile('content/progress/entry');

  api.addFile('menu..');
  api.addComponent('menu/items..');

  api.addComponent('menu/progress..');
  api.addComponent('menu/progress/content..');
  api.addFile('menu/progress/content/component');
  api.addComponent('menu/progress/content/defaultcontent..');
  api.addComponent('menu/progress/content/appcontent..');

  api.addComponent('menu/credits..');

  api.addFile('locations..');
  api.addComponent('locations/mainmenu..');
  api.addFile('locations/play..');

  api.addFile('pixelpad..');

  api.addFile('notifications/randomnotificationsprovider')
  api.addFile('notifications/conditionalnotificationsprovider')
  api.addFile('notifications/tasknotificationsprovider')
  api.addFile('notifications..')

  api.addFile('compositions..')
  api.addFile('compositions/composition')
  api.addFile('compositions/pixelarttools')
  api.addFile('compositions/elementsofart')
});
