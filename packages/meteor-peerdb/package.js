Package.describe({
  name: 'retronator:peerdb',
  summary: "Reactive database layer with references, generators, triggers, migrations, etc.",
  version: '0.27.0',
  git: 'https://github.com/peerlibrary/meteor-peerdb.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'ecmascript',
    'underscore',
    'minimongo',
    'mongo',
    'ddp',
    'logging',
    'promise'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.3.0',
    'peerlibrary:stacktrace@1.3.1_3'
  ]);

  api.export('Document');

  api.addFiles([
    'lib.coffee'
  ]);

  api.addFiles([
    'server.coffee'
  ], 'server');

  api.addFiles([
    'client.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  api.versionsFrom('METEOR@1.8.1');

  api.use([
    'coffeescript@2.4.1',
    'ecmascript',
    'tinytest',
    'test-helpers',
    'insecure',
    'accounts-base',
    'accounts-password',
    'underscore',
    'random',
    'logging',
    'ejson',
    'mongo',
    'ddp'
  ]);

  // Internal dependencies.
  api.use([
    'retronator:peerdb'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.3.0'
  ]);

  api.addFiles([
    'tests_defined.js',
    'tests.coffee'
  ]);
});
