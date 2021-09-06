Package.describe({
  name: 'retronator:peerdb-migrations',
  summary: "PeerDB migrations.",
  version: '1.1.0',
  git: 'https://github.com/peerlibrary/meteor-peerdb-migrations.git'
});

Package.onUse(function (api) {
  // Core dependencies.
  api.use([
    'coffeescript',
    'ecmascript',
    'underscore',
    'minimongo',
    'logging'
  ], 'server');

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert',
    'peerlibrary:directcollection',
    'peerlibrary:peerdb'
  ], 'server');

  api.addFiles([
    'server.coffee'
  ], 'server');
});
