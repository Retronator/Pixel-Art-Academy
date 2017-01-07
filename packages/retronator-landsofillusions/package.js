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
  api.use('retronator:pixelartacademy-cast');

  api.export('Retronator');

  api.addFiles('landsofillusions.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/hallway/hallway.coffee');
  api.addAssets('locations/hallway/operator.script', ['client', 'server']);

  api.addFiles('locations/room/room.coffee');
  api.addAssets('locations/room/operator.script', ['client', 'server']);

});
