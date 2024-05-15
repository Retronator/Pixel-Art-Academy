Package.describe({
  name: 'retronator:pixelartacademy-pico8',
  version: '0.3.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'pngjs': '2.3.0',
  'fast-png': '4.0.1',
  'canvas': '2.6.1'
});

Package.onUse(function(api) {
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartdatabase');
  api.use('froatsnook:request');

  api.use('webapp');
  api.use('http');

  api.export('PixelArtAcademy');

  api.addFile('pico8');
  api.addFile('devkit');
  api.addFile('fanzine');
  api.addFile('cartridges');

  api.addFile('cartridge..');
  api.addServerFile('cartridge/server');

  api.addFile('game..');
  api.addFile('game/game-cartridgeimage');
  api.addServerFile('game/game-server-databasecontent');
  api.addFile('game/subscriptions');

  api.addFile('device..');
  api.addFile('device/device-spritereplacement');
  api.addAssets('device/runtime/pico8.min.js', 'client');
  api.addComponent('device/handheld..');

  api.addFile('pages..');
  api.addComponent('pages/pico8..');
});
