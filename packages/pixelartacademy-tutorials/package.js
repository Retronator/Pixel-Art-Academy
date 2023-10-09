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
  api.use('retronator:pixelartacademy-pixelpad-drawing');
  api.use('retronator:pixelartacademy-pixelpad-instructions');
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addFile('tutorials');

  api.addFile('drawing..');

  api.addFile('drawing/instructions..');
  api.addFile('drawing/instructions/instruction')
  api.addFile('drawing/instructions/generalinstruction')

  api.addComponent('drawing/instructions/desktop..');

  // Pixel art tools

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

  // Elements of art

  api.addFile('drawing/elementsofart..');

  api.addFile('drawing/elementsofart/line..');
  api.addFile('drawing/elementsofart/line/asset');
  api.addFile('drawing/elementsofart/line/straightlines');
  api.addFile('drawing/elementsofart/line/curvedlines');
  api.addFile('drawing/elementsofart/line/brokenlines');
  api.addFile('drawing/elementsofart/line/brokenlines2');
});
