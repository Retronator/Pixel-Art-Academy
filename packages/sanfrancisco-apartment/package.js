Package.describe({
  name: 'retronator:sanfrancisco-apartment',
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

  api.addFile('apartment');

  // Locations

  api.addFile('entrance/entrance');
  api.addFile('hallway/hallway');
  api.addFile('studio/studio');
});
