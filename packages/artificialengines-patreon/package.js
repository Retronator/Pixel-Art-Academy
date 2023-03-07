Package.describe({
  name: 'retronator:artificialengines-patreon',
  version: '1.0.0'
});

Npm.depends({
  'patreon': '0.4.1'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('Artificial');

  // Artificial Telepathy

  api.addServerFile('telepathy/patreon-server');
});
