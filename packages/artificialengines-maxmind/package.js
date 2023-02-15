Package.describe({
  name: 'retronator:artificialengines-maxmind',
  version: '1.0.0'
});

Npm.depends({
  'twit': '2.2.11'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('Artificial');

  // Artificial Telepathy

  api.addServerFile('telepathy/maxmind-server');
});
