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
  api.use('retronator:pixelartacademy-pixelpad-drawing');
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addFile('challenges');

  api.addFile('drawing..');
  api.addFile('drawing/referenceselection');

  // Pixel art software

  api.addFile('drawing/pixelartsoftware..');
  api.addFile('drawing/pixelartsoftware/copyreference');
  api.addFile('drawing/pixelartsoftware/assets');

  api.addUnstyledComponent('drawing/pixelartsoftware/briefcomponent..');

  api.addComponent('drawing/pixelartsoftware/clipboardsecondpagecomponent..');

  api.addFile('drawing/pixelartsoftware/referenceselection..');
  api.addComponent('drawing/pixelartsoftware/referenceselection/portfoliocomponent..');
  api.addComponent('drawing/pixelartsoftware/referenceselection/customcomponent..');
  api.addFile('drawing/pixelartsoftware/referenceselection/customcomponent/card');

  // Pixel art line art

  api.addFile('drawing/pixelartlineart..');
  api.addFile('drawing/pixelartlineart/drawlineart');
  api.addFile('drawing/pixelartlineart/assets');

  api.addFile('drawing/pixelartlineart/referenceselection..');
  api.addComponent('drawing/pixelartlineart/referenceselection/portfoliocomponent..');
  api.addComponent('drawing/pixelartlineart/referenceselection/customcomponent..');

});
