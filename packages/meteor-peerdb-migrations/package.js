Package.describe({
  name: 'retronator:peerdb-migrations',
  summary: "PeerDB migrations.",
  version: '1.1.1',
  git: 'https://github.com/peerlibrary/meteor-peerdb-migrations.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'ecmascript',
    'underscore',
    'minimongo',
    'logging'
  ], 'server');

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.3.0',
    'retronator:directcollection@0.9.0',
    'retronator:peerdb@0.27.0'
  ], 'server');

  api.addFiles([
    'server.coffee'
  ], 'server');
});

Package.onTest(function (api) {
  api.versionsFrom('METEOR@1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'ecmascript',
    'tinytest',
    'test-helpers',
    'underscore',
    'random',
    'logging',
    'ejson',
    'mongo'
  ], 'server');

  // Internal dependencies.
  api.use([
    'retronator:peerdb-migrations'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.3.0',
    'retronator:directcollection@0.9.0',
    'retronator:peerdb@0.27.0'
  ]);

  api.addFiles([
    'tests_migrations.coffee'
  ], 'server');
});
