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

  api.export('PixelArtAcademy');

  api.addFile('episode0');
  
  // Chapter 1

  api.addFile('chapter1/chapter1');

  api.addFile('chapter1/actors/actors');
  api.addFile('chapter1/actors/alex');

  api.addThing('chapter1/items/backpack');
  api.addFile('chapter1/items/passport');
  api.addFile('chapter1/items/acceptanceletter');
  api.addThing('chapter1/items/suitcase');

  // Start

  api.addFile('chapter1/start/start');

  api.addThing('chapter1/start/scenes/terrace');

  // Immigration

  api.addFile('chapter1/immigration/immigration');

  api.addThing('chapter1/immigration/scenes/concourse');
  api.addFile('chapter1/immigration/scenes/immigration');
  api.addThing('chapter1/immigration/scenes/baggageclaim');
  api.addThing('chapter1/immigration/scenes/customs');

  // Airships

  api.addFile('chapter1/airship/airship');

  api.addThing('chapter1/airship/scenes/arrivals');
  api.addThing('chapter1/airship/scenes/tower');
});
