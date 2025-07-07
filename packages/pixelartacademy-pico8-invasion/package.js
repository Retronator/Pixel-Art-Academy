Package.describe({
  name: 'retronator:pixelartacademy-pico8-invasion',
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

  api.export('PixelArtAcademy');

  api.addFile('invasion');
  api.addServerFile('server');

  api.addFile('project');
  api.addFile('project-startend');

  api.addAssets('invasion.p8.png', 'client');
});
