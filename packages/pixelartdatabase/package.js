Package.describe({
  name: 'retronator:pixelartdatabase',
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

  api.export('PixelArtDatabase');

  api.addFiles('pixelartdatabase.coffee');

  api.addFiles('artist/artist.coffee');
  api.addFiles('artist/server.coffee', 'server');
  api.addFiles('artist/methods.coffee');
  api.addFiles('artist/subscriptions.coffee', 'server');

  api.addFiles('artwork/artwork.coffee');
  api.addFiles('artwork/methods.coffee');
  api.addFiles('artwork/subscriptions.coffee', 'server');

  api.addFiles('character/character.coffee');

  api.addFiles('profile/profile.coffee');
  api.addFiles('profile/server.coffee', 'server');
  api.addFiles('profile/subscriptions.coffee', 'server');

  api.addFiles('profile/providers-server/providers.coffee', 'server');
  api.addFiles('profile/providers-server/twitter.coffee', 'server');

  api.addFiles('components/components.coffee');

  api.addFiles('components/stream/stream.coffee');
  api.addFiles('components/stream/stream.styl');
  api.addFiles('components/stream/stream.html');

  /*
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
  */

});
