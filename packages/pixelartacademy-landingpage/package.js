Package.describe({
  name: 'retronator:pixelartacademy-landingpage',
  version: '0.0.1',
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
  api.use('retronator:artificialengines');
  api.use('retronator:retronator-store');
  api.use('retronator:retronator-hq');

  api.export('PixelArtAcademy');

  api.addFile('landingpage');

  // Pages

  api.addFile('pages/pages');

  api.addFile('pages/components/components');
  api.addComponent('pages/components/retropolis/retropolis');

  api.addComponent('pages/about/about');
  api.addComponent('pages/press/press');
  api.addComponent('pages/smallprint/smallprint');
});
