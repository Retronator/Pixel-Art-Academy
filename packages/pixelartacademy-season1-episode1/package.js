Package.describe({
  name: 'retronator:pixelartacademy-season1-episode1',
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
  api.use('retronator:pixelartacademy-season1');
  api.use('retronator:landsofillusions');
  api.use('retronator:retronator-hq');
  api.use('retronator:sanfrancisco-soma');
  api.use('retronator:sanfrancisco-apartment');

  api.export('PixelArtAcademy');

  api.addFile('episode1');
  api.addFile('scenes/inventory');
  api.addFile('scenes/characters');
  api.addFile('scenes/chinabasinpark');

  // Start

  api.addFile('start/start');
  api.addThing('start/scenes/wakeup');

  // Chapter 1

  api.addFile('chapter1/chapter1');

  // Intro

  api.addFile('chapter1/sections/intro/intro');

  api.addThing('chapter1/sections/intro/scenes/studio');
});
