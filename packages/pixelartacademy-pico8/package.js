Package.describe({
  name: 'retronator:pixelartacademy-pico8',
  version: '0.2.0',
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

  api.addFiles('runtime/picoloader.js', 'client');
  api.addServerFile('server');

  //api.addAssets('runtime/pico8.js', 'client');
  api.addAssets('runtime/pico8.min.js', 'client');
});
