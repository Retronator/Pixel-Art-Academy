Package.describe({
  name: 'retronator:pixelartacademy-pico8-snake',
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
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-pico8');
  api.use('retronator:pixelartacademy-season1-episode1');

  api.export('PixelArtAcademy');

  api.addServerFile('server');
  api.addAssets('snake.p8.png', 'client');
});
