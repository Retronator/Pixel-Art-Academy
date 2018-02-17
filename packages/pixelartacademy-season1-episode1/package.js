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
  api.use('retronator:pixelartacademy-learning');
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

  api.addFile('start..');
  api.addThing('start/scenes/wakeup');

  // Chapter 1: Admission Week

  api.addFile('chapter1..');
  api.addServerFile('chapter1/chapter1-server');
  api.addServerFile('chapter1/methods-server');

  api.addFile('chapter1/events..');
  api.addFile('chapter1/events/applicationaccepted');

  api.addFile('chapter1/items..');
  api.addFile('chapter1/items/admissionemail');

  api.addFile('chapter1/scenes/inbox');

  api.addFile('chapter1/goals..');
  api.addFile('chapter1/goals/tools..');
  api.addFile('chapter1/goals/tools/software');

  // Intro
  api.addFile('chapter1/sections/intro..');
  api.addThing('chapter1/sections/intro/scenes/studio');

  // Waiting
  api.addFile('chapter1/sections/waiting..');

  // Pre-PixelBoy
  api.addFile('chapter1/sections/prepixelboy..');
  api.addThing('chapter1/sections/prepixelboy/scenes/store');

  // PixelBoy
  api.addFile('chapter1/sections/pixelboy..');
  api.addThing('chapter1/sections/pixelboy/scenes/store');

  // Post-PixelBoy
  api.addFile('chapter1/sections/postpixelboy..');
  api.addThing('chapter1/sections/postpixelboy/scenes/store');
});
