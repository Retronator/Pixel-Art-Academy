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
  api.addFile('drawing/instructions/completeinstruction')
  api.addFile('drawing/instructions/stepinstruction')

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
  api.addFile('drawing/elementsofart/line/assetwithreferences');

  api.addFile('drawing/elementsofart/line/straightlines');
  api.addFile('drawing/elementsofart/line/curvedlines');
  api.addFile('drawing/elementsofart/line/brokenlines');
  api.addFile('drawing/elementsofart/line/brokenlines2');
  api.addFile('drawing/elementsofart/line/outlines');
  api.addFile('drawing/elementsofart/line/outlines2');
  api.addFile('drawing/elementsofart/line/edges');
  api.addFile('drawing/elementsofart/line/patterns');

  api.addFile('drawing/elementsofart/line/errorinstruction');
  api.addFile('drawing/elementsofart/line/referencestrayinstruction');

  // Pixel art fundamentals

  api.addFile('drawing/pixelartfundamentals..');
  api.addFile('drawing/pixelartfundamentals/markup');

  api.addFile('drawing/pixelartfundamentals/jaggies..');
  api.addFile('drawing/pixelartfundamentals/jaggies/asset');

  api.addFile('drawing/pixelartfundamentals/jaggies/lines..');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/intendedandperceivedlines');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/jaggies');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/corners');

  api.addFile('drawing/pixelartfundamentals/jaggies/lines/lineartcleanup..');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/lineartcleanup/steps');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/lineartcleanup/instructions');

  api.addFile('drawing/pixelartfundamentals/jaggies/lines/jaggies2..');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/jaggies2/steps');
  api.addFile('drawing/pixelartfundamentals/jaggies/lines/jaggies2/instructions');

  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals..');
  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/evendiagonals');
  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/constrainingangles');
  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/unevendiagonals');
  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/unevendiagonalsartstyle');

  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/diagonalsevaluation..');
  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/diagonalsevaluation/steps');
  api.addFile('drawing/pixelartfundamentals/jaggies/diagonals/diagonalsevaluation/instructions');

  api.addFile('drawing/pixelartfundamentals/jaggies/curves..');
  api.addFile('drawing/pixelartfundamentals/jaggies/curves/smoothcurves');
  api.addFile('drawing/pixelartfundamentals/jaggies/curves/circles');
  api.addFile('drawing/pixelartfundamentals/jaggies/curves/longcurves');

  api.addFile('drawing/pixelartfundamentals/jaggies/curves/lineartcleanup..');
  api.addFile('drawing/pixelartfundamentals/jaggies/curves/lineartcleanup/steps');
  api.addFile('drawing/pixelartfundamentals/jaggies/curves/lineartcleanup/instructions');
});
