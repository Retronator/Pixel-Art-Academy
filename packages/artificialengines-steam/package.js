Package.describe({
  name: 'retronator:artificialengines-steam',
  version: '1.0.0'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('Artificial');

  // Artificial Telepathy

  api.addFile('telepathy/steam..');
  api.addFile('telepathy/steam/player');
  api.addFile('telepathy/steam/cloud');
  api.addFile('telepathy/steam/app');
});
