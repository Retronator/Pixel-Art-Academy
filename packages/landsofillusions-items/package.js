Package.describe({
  name: 'retronator:landsofillusions-items',
  version: '0.1.0',
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

  api.export('LandsOfIllusions');

  api.addFile('items');

  api.addFile('components..');
  api.addComponent('components/map..');
  api.addComponent('components/map/node');

  api.addComponent('map..');

  api.addComponent('sync..');
  api.addFile('sync/sync-tab');

  api.addComponent('sync/map..');

  api.addComponent('sync/memories..');
  api.addComponent('sync/memories/contexts/journalentry..');

  api.addComponent('sync/immersion..');
});
