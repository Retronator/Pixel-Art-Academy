Package.describe({
  name: 'retronator:artificialengines-pages',
  version: '1.0.0'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');
  api.use('retronator:retronator');
  api.use('retronator:retronator-accounts');

  api.export('Artificial');

  api.addFile('pages');

  api.addFile('babel/pages');
  api.addUnstyledComponent('babel/admin/admin');
  api.addUnstyledComponent('babel/admin/scripts/scripts');
  api.addServerFile('babel/admin/scripts/methods-server/generatebesttranslations');
});
