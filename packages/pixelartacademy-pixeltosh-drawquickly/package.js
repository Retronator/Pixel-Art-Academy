Package.describe({
  name: 'retronator:pixelartacademy-pixeltosh-drawquickly',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'bresenham-zingl': '0.2.0',
  'onnxruntime-web': '1.16.3'
});

Package.onUse(function(api) {
  api.use('retronator:fatamorgana');
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-learnmode');
  api.use('retronator:pixelartacademy-pixeltosh');

  api.export('PixelArtAcademy');

  api.addFile('drawquickly');
  api.addFile('classifier');
  api.addFile('drawing');
  api.addFile('symbolicdrawing');
  api.addFile('symbolicdrawing-things');
  api.addFile('realisticdrawing');
  api.addFile('timer');

  api.addFile('interface..');

  api.addFile('interface/actions..');
  api.addFile('interface/actions/about');

  api.addComponent('interface/about..');

  api.addComponent('interface/game..');
  api.addComponent('interface/game/splash..');
  api.addComponent('interface/game/mode..');
  api.addComponent('interface/game/difficulty..');
  api.addComponent('interface/game/speed..');
  api.addComponent('interface/game/thing..');
  api.addComponent('interface/game/instructions..');

  api.addStyledFile('interface/game/draw..');
  api.addComponent('interface/game/draw/symbolicdrawing..');
  api.addComponent('interface/game/draw/symbolicdrawing/things..');
  api.addComponent('interface/game/draw/realisticdrawing..');
  api.addComponent('interface/game/draw/realisticdrawing/references..');
  api.addComponent('interface/game/draw/canvas..');
  api.addComponent('interface/game/draw/timer..');

  api.addStyledFile('interface/game/results..');
  api.addComponent('interface/game/results/symbolicdrawing..');
  api.addComponent('interface/game/results/realisticdrawing..');
  api.addComponent('interface/game/results/drawing..');
});
