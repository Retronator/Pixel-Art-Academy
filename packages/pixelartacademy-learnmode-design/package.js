Package.describe({
  name: 'retronator:pixelartacademy-learnmode-design',
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
  api.use('retronator:pixelartacademy-learnmode');
  api.use('retronator:pixelartacademy-pixelpad-music');
  api.use('retronator:pixelartacademy-pixelpad-notifications');

  api.export('PixelArtAcademy');

  api.addFile('design');

  // Start

  api.addFile('start..');

  // Fundamentals

  api.addFile('fundamentals..');

  api.addFile('fundamentals/goals..');
  api.addFile('fundamentals/goals/shapelanguage');
  api.addFile('fundamentals/goals/invasion');

  api.addFile('fundamentals/scenes/tutorialsdrawing');
  api.addFile('fundamentals/scenes/pico8cartridges');
  api.addFile('fundamentals/scenes/workbench');
  api.addFile('fundamentals/scenes/pixeltoshfiles');

  api.addFile('fundamentals/content..');
  api.addFile('fundamentals/content/course');
  api.addFile('fundamentals/content/goals');
  api.addFile('fundamentals/content/drawingtutorials');
  api.addFile('fundamentals/content/projects');
});
