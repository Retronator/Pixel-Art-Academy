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
});
