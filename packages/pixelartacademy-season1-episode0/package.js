Package.describe({
  name: 'retronator:pixelartacademy-season1-episode0',
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
  api.use('retronator:retropolis-spaceport');
  api.use('retronator:retronator-hq');
  api.use('retronator:sanfrancisco-soma');

  api.export('PixelArtAcademy');

  api.addFile('episode0');

  // Start

  api.addFile('start/start');

  // Chapter 1

  api.addComponent('chapter1/chapter1');

  api.addFile('chapter1/scenes/inventory');

  api.addFile('chapter1/actors/actors');
  api.addFile('chapter1/actors/alex');

  api.addFile('chapter1/items/items');
  api.addThing('chapter1/items/backpack');
  api.addFile('chapter1/items/passport');
  api.addFile('chapter1/items/acceptanceletter');
  api.addThing('chapter1/items/suitcase');

  // Start

  api.addFile('chapter1/sections/start/start');

  api.addThing('chapter1/sections/start/scenes/terrace');

  // Immigration

  api.addFile('chapter1/sections/immigration/immigration');

  api.addThing('chapter1/sections/immigration/scenes/concourse');
  api.addFile('chapter1/sections/immigration/scenes/immigration');
  api.addThing('chapter1/sections/immigration/scenes/baggageclaim');
  api.addThing('chapter1/sections/immigration/scenes/customs');

  // Airships

  api.addFile('chapter1/sections/airship/airship');

  api.addThing('chapter1/sections/airship/scenes/arrivals');
  api.addThing('chapter1/sections/airship/scenes/tower');
  api.addThing('chapter1/sections/airship/scenes/terminal');
  api.addThing('chapter1/sections/airship/scenes/dock');
  api.addThing('chapter1/sections/airship/scenes/cabin');

  // Chapter 2

  api.addComponent('chapter2/chapter2');

  api.addFile('chapter2/scenes/inventory');
  api.addFile('chapter2/scenes/store');

  api.addFile('chapter2/actors/actors');
  api.addFile('chapter2/actors/conductor');

  api.addFile('chapter2/items/items');
  api.addComponent('chapter2/items/videotablet/videotablet');
  api.addFile('chapter2/items/videotablet/videos');

  // Intro

  api.addFile('chapter2/sections/intro/intro');

  api.addThing('chapter2/sections/intro/scenes/caltrain');
  api.addFile('chapter2/sections/intro/scenes/2nd');

  // Registration

  api.addFile('chapter2/sections/registration/registration');

  api.addThing('chapter2/sections/registration/scenes/cafe');

  // Shopping

  api.addFile('chapter2/sections/shopping/shopping');

  // Immersion

  api.addThing('chapter2/sections/immersion/immersion');
  api.addServerFile('chapter2/sections/immersion/methods-server');

  api.addThing('chapter2/sections/immersion/scenes/basement');
  api.addThing('chapter2/sections/immersion/scenes/landsofillusions');
  api.addThing('chapter2/sections/immersion/scenes/room');

  // Chapter 3

  api.addFile('chapter3/chapter3');

  api.addFile('chapter3/scenes/inventory');
  api.addFile('chapter3/scenes/2nd');
  api.addFile('chapter3/scenes/4thking');
  api.addFile('chapter3/scenes/cafe');

  api.addFile('chapter3/items/items');

  // Construct

  api.addFile('chapter3/sections/construct/construct');

  api.addThing('chapter3/sections/construct/scenes/loading');
});
