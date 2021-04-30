Package.describe({
  name: 'retronator:sanfrancisco-soma',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:sanfrancisco');
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');

  api.export('SanFrancisco');

  api.addFile('soma');

  // Actors

  api.addFile('actors..');
  api.addThing('actors/james..');

  // Items

  api.addFile('items..');

  api.addComponent('items/map..');
  api.addThing('items/muni..');

  // Locations

  api.addFile('caltrain..');
  api.addFile('4thking..');
  api.addFile('moscone..');
  api.addFile('moscone/station');
  api.addFile('2nd..');
  api.addFile('2nd/retronatorhq');
  api.addFile('2nd/artistsign');
  api.addFile('2ndking..');
  api.addFile('c3..');
  api.addFile('missionbay..');
  api.addFile('missionrock..');
  api.addFile('chinabasinpark..');
  api.addFile('transbay..');
});
