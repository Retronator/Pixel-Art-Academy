Package.describe({
  name: 'retronator:pixelartacademy-challenges',
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
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addFile('challenges');

  api.addFile('drawing..');

  api.addFile('drawing/pixelartsoftware..');
  api.addFile('drawing/pixelartsoftware/copyreference');
  api.addFile('drawing/pixelartsoftware/errorenginecomponent');
  api.addFile('drawing/pixelartsoftware/assets');
  api.addUnstyledComponent('drawing/pixelartsoftware/briefcomponent..');
  api.addComponent('drawing/pixelartsoftware/clipboardpagecomponent..');

  api.addFile('drawing/tutorial..');

  api.addFile('drawing/tutorial/basics..');
  api.addFile('drawing/tutorial/basics/pencil');
  api.addFile('drawing/tutorial/basics/eraser');
  api.addFile('drawing/tutorial/basics/colorfill');
  api.addFile('drawing/tutorial/basics/colorfill2');
  api.addFile('drawing/tutorial/basics/colorfill3');
  api.addFile('drawing/tutorial/basics/basictools');
  api.addFile('drawing/tutorial/basics/shortcuts');
  api.addFile('drawing/tutorial/basics/references');

  api.addFile('drawing/tutorial/colors..');
  api.addFile('drawing/tutorial/colors/colorswatches');
  api.addFile('drawing/tutorial/colors/colorpicking');
  api.addFile('drawing/tutorial/colors/quickcolorpicking');
  api.addServerFile('drawing/tutorial/colors/palette-server');

  api.addFile('drawing/tutorial/helpers..');
  api.addFile('drawing/tutorial/helpers/zoom');
  api.addFile('drawing/tutorial/helpers/movecanvas');
  api.addFile('drawing/tutorial/helpers/undoredo');
  api.addFile('drawing/tutorial/helpers/lines');
});
