Package.describe({
  name: 'retronator:pixelartacademy-learnmode-intro',
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

  api.export('PixelArtAcademy');

  api.addFile('intro');
  api.addFile('scenes/pixelboy');
  api.addFile('scenes/apps');
  api.addFile('scenes/editors');
  api.addFile('scenes/challengesdrawing');
  api.addFile('scenes/tutorialsdrawing');
  api.addFile('scenes/pico8cartridges');

  // Start

  api.addFile('start..');

  // Tutorial

  api.addFile('tutorial..');

  api.addFile('tutorial/goals..');
  api.addFile('tutorial/goals/tutorial');
  api.addFile('tutorial/goals/pixelartsoftware');
  api.addFile('tutorial/goals/studyplan');
  api.addFile('tutorial/goals/snake');
});
