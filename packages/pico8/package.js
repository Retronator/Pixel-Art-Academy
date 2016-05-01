Package.describe({
  name: 'pico8',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'pngjs': '2.3.0'
});

Package.onUse(function(api) {
  api.use('coffeescript');
  api.use('webapp');
  api.use('http');
  api.use('froatsnook:request');
  api.use('retronator:landsofillusions');

  api.export('Pico');

  api.addFiles('palette.coffee', 'server');

  api.addFiles('picoloader.js', 'client');
  api.addFiles('server.coffee', 'server');

  //api.addAssets('pico8.js', 'client');
  api.addAssets('pico8.min.js', 'client');
});
