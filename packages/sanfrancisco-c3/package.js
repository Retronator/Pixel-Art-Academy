Package.describe({
  name: 'retronator:sanfrancisco-c3',
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

  api.export('SanFrancisco');

  api.addFile('c3');

  // Actors

  api.addFile('actors/actors');
  api.addFile('actors/receptionist');
  api.addFile('actors/drshelley');

  // Locations

  api.addFile('behavior/behavior');
  api.addThing('design/design');
  api.addFile('hallway/hallway');
  api.addThing('lobby/lobby');
  api.addFile('stasis/stasis');

});
