Package.describe({
  name: 'retronator:pixelartacademy-pixelboy-drawing',
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
  api.use('retronator:fatamorgana');
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-pixelboy');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addComponent('drawing');

  api.addComponent('portfolio..');
  api.addFile('portfolio/portfolio-initialize');
  api.addFile('portfolio/asset');
  api.addFile('portfolio/formasset');
  api.addServerFile('portfolio/subscriptions');

  api.addFile('portfolio/artworkasset..');
  api.addComponent('portfolio/artworkasset/portfoliocomponent..');

  api.addFile('portfolio/newartwork..');
  api.addComponent('portfolio/newartwork/portfoliocomponent..');
  api.addComponent('portfolio/newartwork/clipboardcomponent..');

  api.addFile('portfolio/importartwork..');

  api.addComponent('clipboard..');

  api.addFile('editor..');
  api.addFile('editor/editors');
  api.addComponent('editor/desktop..');
  api.addComponent('editor/desktop/colorfill..');
  api.addComponent('editor/desktop/palette..');
  api.addComponent('editor/desktop/references..');
  api.addComponent('editor/desktop/references/reference..');
  api.addComponent('editor/desktop/pico8..');
  api.addFile('editor/desktop/tools..');
  api.addFile('editor/desktop/tools/movecanvas');
});
