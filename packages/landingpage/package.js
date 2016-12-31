Package.describe({
  name: 'retronator:landingpage',
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
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');

  api.export('Retronator');

  api.addFiles('landingpage.coffee');

  // Locations

  api.addFiles('locations/locations.coffee');

  api.addFiles('locations/retropolis/retropolis.coffee');
  api.addFiles('locations/retropolis/retropolis.html');
  api.addFiles('locations/retropolis/retropolis.styl');

  // Items

  api.addFiles('items/items.coffee');

  api.addFiles('items/prospectus/prospectus.coffee');

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/about/about.coffee');
  api.addFiles('pages/about/about.styl');
  api.addFiles('pages/about/about.html');
});
