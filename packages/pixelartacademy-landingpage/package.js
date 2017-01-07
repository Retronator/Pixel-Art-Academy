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

  api.export('PixelArtAcademy');

  api.addFiles('landingpage.coffee');

  // Pages

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/about/about.coffee');
  api.addFiles('pages/about/about.styl');
  api.addFiles('pages/about/about.html');

  api.addFiles('pages/press/press.coffee');
  api.addFiles('pages/press/press.styl');
  api.addFiles('pages/press/press.html');
});
