Package.describe({
  name: 'retronator:artificialengines-stripe',
  version: '1.0.0'
});

Npm.depends({
  'stripe': '5.1.1'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('Artificial');

  // Artificial Telepathy

  api.addServerFile('telepathy/twitter-server');
});
