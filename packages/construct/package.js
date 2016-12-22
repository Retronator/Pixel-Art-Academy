Package.describe({
  name: 'retronator:construct',
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
  api.use('retronator:hq');

  api.export('LandsOfIllusions');

  api.addFiles('construct.coffee');
  api.addFiles('location.coffee');
  api.addAssets('operator.script', ['client', 'server']);

  // Actors

  api.addFiles('actors/actors.coffee');
  api.addFiles('actors/captain.coffee');

  // Items

  api.addFiles('items/items.coffee');
  api.addFiles('items/operatorlink.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');
  
  api.addFiles('locations/loading/loading.coffee');
  api.addFiles('locations/loading/loading.styl');
  api.addAssets('locations/loading/captain.script', ['client', 'server']);

  api.addFiles('locations/loading/tv/tv.coffee');
  api.addFiles('locations/loading/tv/tv.html');
  api.addFiles('locations/loading/tv/tv.styl');

  api.addFiles('locations/c3/c3.coffee');
  api.addFiles('locations/c3/entrance/entrance.coffee');
  api.addFiles('locations/c3/lobby/lobby.coffee');

});
