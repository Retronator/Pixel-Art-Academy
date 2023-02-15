Package.describe({
  name: 'retronator:artificialengines-tumblr',
  version: '1.0.0'
});

Npm.depends({
  'tumblr.js': '1.1.1'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');

  api.export('Artificial');

  // Artificial Telepathy

  api.addServerFile('telepathy/tumblr-server');
});
