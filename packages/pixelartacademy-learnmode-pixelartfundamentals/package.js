Package.describe({
  name: 'retronator:pixelartacademy-learnmode-pixelartfundamentals',
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
  api.use('retronator:pixelartacademy-pixeltosh-pinball');
  api.use('retronator:pixelartacademy-learnmode');
  api.use('retronator:pixelartacademy-pixelpad-music');
  api.use('retronator:pixelartacademy-pixelpad-notifications');
  api.use('retronator:pixelartacademy-publication');

  api.export('PixelArtAcademy');

  api.addFile('pixelartfundamentals');

  api.addFile('scenes/apps');
  api.addFile('scenes/systems');

  // Start

  api.addFile('start..');

  // Fundamentals

  api.addFile('fundamentals..');
  api.addFile('fundamentals/scenes/tutorialsdrawing');
  api.addFile('fundamentals/scenes/challengesdrawing');
  api.addFile('fundamentals/scenes/apps');
  api.addFile('fundamentals/scenes/pixeltoshprograms');
  api.addFile('fundamentals/scenes/pixeltoshfiles');
  api.addFile('fundamentals/scenes/workbench');
  api.addFile('fundamentals/scenes/musictapes');

  api.addFile('fundamentals/goals..');
  api.addFile('fundamentals/goals/elementsofart');
  api.addFile('fundamentals/goals/jaggies');

  api.addFile('fundamentals/goals/pinball..');
  api.addFile('fundamentals/goals/pinball/assetstask');
  api.addFile('fundamentals/goals/pinball/tasks');

  api.addFile('fundamentals/content..');
  api.addFile('fundamentals/content/course');
  api.addFile('fundamentals/content/apps');
  api.addFile('fundamentals/content/goals');
  api.addFile('fundamentals/content/drawingtutorials');
  api.addFile('fundamentals/content/drawingchallenges');
  api.addFile('fundamentals/content/projects');
  api.addFile('fundamentals/content/drawingeditors');
  api.addFile('fundamentals/content/storylines');

  api.addFile('fundamentals/publications..')
  api.addStyledFile('fundamentals/publications/pinballmagazine..')
  api.addStyle('fundamentals/publications/pinballmagazine/pinballmagazine-cover')
  api.addStyle('fundamentals/publications/pinballmagazine/pinballmagazine-tableofcontents')

  api.addStyle('fundamentals/publications/pinballmagazine/themes/brown-0-gray-3')
  api.addStyle('fundamentals/publications/pinballmagazine/themes/orange-3-brown-6')
  api.addStyle('fundamentals/publications/pinballmagazine/themes/red-1-red-1')

  api.addStyle('fundamentals/publications/pinballmagazine/contentpart/contents')
  api.addStyle('fundamentals/publications/pinballmagazine/contentpart/headerfooter')
  api.addStyle('fundamentals/publications/pinballmagazine/contentpart/figure')

  api.addStyle('fundamentals/publications/pinballmagazine/issues/1/cover')
  api.addStyle('fundamentals/publications/pinballmagazine/issues/1/prewarhistory')
  api.addStyle('fundamentals/publications/pinballmagazine/issues/1/gobbleholes')
  api.addStyle('fundamentals/publications/pinballmagazine/issues/1/bumpers')
});
