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
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-pixelboy');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addComponent('drawing');

  api.addComponent('portfolio..');
  api.addFile('portfolio/portfolio-initialize');

  api.addComponent('clipboard..');

  api.addComponent('editor..');
  api.addFile('editor/theme..');
  api.addComponent('editor/theme/school..');
  api.addComponent('editor/theme/school/colorfill..');
  api.addComponent('editor/theme/school/palette..');
  api.addComponent('editor/theme/school/references..');
  api.addComponent('editor/theme/school/references/reference..');
});
