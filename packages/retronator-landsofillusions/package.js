Package.describe({
  name: 'retronator:retronator-landsofillusions',
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
  api.use('retronator:landsofillusions');
  api.use('retronator:retronator');
  api.use('retronator:retronator-store');
  api.use('retronator:retronator-hq');

  api.export('Retronator');

  api.addFile('landsofillusions');

  // Locations

  api.addFile('hallway/hallway');

  api.addThing('room/room');
  api.addFile('room/chair/chair');

});
