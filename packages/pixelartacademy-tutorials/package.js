Package.describe({
  name: 'retronator:pixelartacademy-tutorials',
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
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartacademy-pixelboy-drawing');
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addFile('tutorials');

  api.addFile('drawing..');

  api.addFile('drawing/pixelarttools..');

  api.addFile('drawing/pixelarttools/basics..');
  api.addFile('drawing/pixelarttools/basics/pencil');
  api.addFile('drawing/pixelarttools/basics/eraser');
  api.addFile('drawing/pixelarttools/basics/colorfill');
  api.addFile('drawing/pixelarttools/basics/colorfill2');
  api.addFile('drawing/pixelarttools/basics/colorfill3');
  api.addFile('drawing/pixelarttools/basics/basictools');
  api.addFile('drawing/pixelarttools/basics/shortcuts');
  api.addFile('drawing/pixelarttools/basics/references');

  api.addFile('drawing/pixelarttools/colors..');
  api.addFile('drawing/pixelarttools/colors/colorswatches');
  api.addFile('drawing/pixelarttools/colors/colorpicking');
  api.addFile('drawing/pixelarttools/colors/quickcolorpicking');
  api.addServerFile('drawing/pixelarttools/colors/palette-server');

  api.addFile('drawing/pixelarttools/helpers..');
  api.addFile('drawing/pixelarttools/helpers/zoom');
  api.addFile('drawing/pixelarttools/helpers/movecanvas');
  api.addFile('drawing/pixelarttools/helpers/undoredo');
  api.addFile('drawing/pixelarttools/helpers/lines');
});