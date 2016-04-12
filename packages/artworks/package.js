Package.describe({
  name: 'artworks',
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
  api.use('pixelboy');
  api.use('edgee:slingshot');

  api.export('PixelArtAcademy');

  api.addFiles('artworks.coffee');
  api.addFiles('client.coffee', 'client');
  api.addFiles('server.coffee', 'server');

  api.addFiles('artist/artist.coffee');
  api.addFiles('artist/methods.coffee', 'server');
  api.addFiles('artist/subscriptions.coffee', 'server');

  api.addFiles('artwork/artwork.coffee');
  api.addFiles('artwork/methods.coffee', 'server');
  api.addFiles('artwork/subscriptions.coffee', 'server');

  api.addFiles('calendar/artworks.coffee');

  api.addFiles('components/components.coffee');

  api.addFiles('components/uploader/uploader.html');
  api.addFiles('components/uploader/uploader.coffee');

  api.addFiles('components/admin/admin.coffee');

  api.addFiles('components/admin/artist/artists.coffee');
  api.addFiles('components/admin/artist/artist.coffee');
  api.addFiles('components/admin/artist/artist.html');

  api.addFiles('components/admin/artwork/artworks.coffee');
  api.addFiles('components/admin/artwork/artwork.coffee');
  api.addFiles('components/admin/artwork/artwork.html');
  api.addFiles('components/admin/artwork/artwork.styl');
});
