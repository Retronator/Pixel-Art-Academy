Package.describe({
  name: 'retronator:pixelartacademy-pixelpad-drawing',
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
  api.use('retronator:pixelartacademy-pixelpad');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartacademy-learnmode');
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
  api.addComponent('portfolio/artworkasset/clipboardcomponent..');

  api.addFile('portfolio/newartwork..');
  api.addComponent('portfolio/newartwork/portfoliocomponent..');
  api.addComponent('portfolio/newartwork/clipboardcomponent..');

  api.addFile('portfolio/importartwork..');
  api.addComponent('portfolio/importartwork/portfoliocomponent..');
  api.addComponent('portfolio/importartwork/clipboardcomponent..');

  api.addComponent('clipboard..');

  api.addFile('editor..');
  api.addStyle('editor..');
  api.addFile('editor/editors');
  api.addFile('editor/assetloader');
  api.addFile('editor/pixelcanvascomponents');
  api.addFile('editor/colorhelp');

  api.addFile('editor/tools..');
  api.addFile('editor/tools/movecanvas');
  api.addFile('editor/tools/analyze');

  api.addComponent('editor/desktop..');
  api.addComponent('editor/desktop/pixelcanvas..');
  api.addComponent('editor/desktop/testpaper..');
  api.addComponent('editor/desktop/colorfill..');
  api.addComponent('editor/desktop/zoom..');
  api.addComponent('editor/desktop/pico8..');

  api.addComponent('editor/desktop/palette..');
  api.addComponent('editor/desktop/palette/colorhelp..');

  api.addComponent('editor/desktop/pixelartevaluation..');
  api.addComponent('editor/desktop/pixelartevaluation/overview..');
  api.addComponent('editor/desktop/pixelartevaluation/pixelperfectlines..');
  api.addComponent('editor/desktop/pixelartevaluation/evendiagonals..');
  api.addComponent('editor/desktop/pixelartevaluation/smoothcurves..');
  api.addComponent('editor/desktop/pixelartevaluation/consistentlinewidth..');

  api.addUnstyledComponent('editor/desktop/references..');
  api.addComponent('editor/desktop/references/displaycomponent..');
  api.addComponent('editor/desktop/references/displaycomponent/reference..');

  api.addComponent('editor/desktop/publications..');

  api.addFile('editor/desktop/actions..');
  api.addFile('editor/desktop/actions/focus');
  api.addFile('editor/desktop/actions/zoom');

  api.addComponent('editor/easel..');
  api.addComponent('editor/easel/layout..');
  api.addComponent('editor/easel/pixelcanvas..');
  api.addComponent('editor/easel/colorfill..');

  api.addFile('editor/easel/tools..');
  api.addFile('editor/easel/tools/brush..');
  api.addFile('editor/easel/tools/brush/square');
  api.addFile('editor/easel/tools/brush/pixel');
  api.addFile('editor/easel/tools/brush/round');

  api.addFile('editor/easel/actions..');
  api.addFile('editor/easel/actions/displaymode');
  api.addFile('editor/easel/actions/clearpaint');
});
