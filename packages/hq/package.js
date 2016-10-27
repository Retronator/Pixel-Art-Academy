Package.describe({
  name: 'retronator:hq',
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
  api.use('retronator:cast');

  api.export('Retronator');

  api.addFiles('hq.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/lobby.coffee');
  api.addAssets('locations/lobby-retro.script', ['client', 'server']);

  api.addFiles('locations/lobby-elevator.coffee');

  api.addFiles('locations/store.coffee');

  api.addFiles('locations/store-elevator.coffee');

  // Items

  api.addFiles('items/items.coffee');

  api.addFiles('items/wallet/wallet.coffee');
  api.addFiles('items/wallet/wallet.html');
  api.addFiles('items/wallet/wallet.styl');

});
