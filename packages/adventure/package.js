Package.describe({
  name: 'adventure',
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
  api.use('pixelartacademy');

  api.export('PixelArtAcademy');

  api.addFiles('adventure.coffee');
  api.addFiles('adventure.styl');

  api.addFiles('locations/locations.coffee');
  api.addFiles('locations/dorm.coffee');
  api.addFiles('locations/studio.coffee');

  api.addFiles('assets/jquery.blast.min.js', 'client')
});
