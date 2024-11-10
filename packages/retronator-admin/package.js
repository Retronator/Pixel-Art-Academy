Package.describe({
  name: 'retronator:retronator-admin',
  version: '1.0.0'
});

Package.onUse(function(api) {
  api.use('facts-base');
  api.use('facts-ui');

  api.use('retronator:artificialengines');
  api.use('retronator:retronator');

  api.export('Retronator');

  api.addUnstyledComponent('admin');
  api.addUnstyledComponent('facts..');
  api.addServerFile('facts/server');
});
