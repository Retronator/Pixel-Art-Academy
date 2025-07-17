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

Npm.depends({
  'stackblur-canvas': '2.4.0'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');

  api.export('PixelArtDatabase');

  api.addFile('pixelartdatabase');
  api.addServerFile('server');

  // Artist

  api.addFile('artist..');
  api.addFile('artist/artist-create');
  api.addFile('artist/methods');
  api.addServerFile('artist/subscriptions');

  // Artwork

  api.addFile('artwork..');
  api.addFile('artwork/artwork-create');
  api.addFile('artwork/artwork-updateartwork');
  api.addFile('artwork/methods');
  api.addServerFile('artwork/subscriptions');
  api.addFile('artwork/migrations/0000-converttohttps');

  // Character

  api.addFile('character..');

  // Profile

  api.addFile('profile..');
  api.addServerFile('profile/server');
  api.addServerFile('profile/subscriptions');
  api.addServerFile('profile/methods-server');

  api.addServerFile('profile/providers-server/providers');
  api.addServerFile('profile/providers-server/twitter');

  // Website

  api.addFile('website..');
  api.addServerFile('website/methods-server');
  api.addServerFile('website/subscriptions');

  // Components

  api.addFile('components..');
  api.addComponent('components/stream..');
  api.addComponent('components/stream/artwork');
  api.addClientFile('components/stream/artwork-renderbackground-client');

  // Pages

  api.addFile('pages..');

  // Admin

  api.addUnstyledComponent('pages/admin..');

  api.addFile('pages/admin/artists..');
  api.addUnstyledComponent('pages/admin/artists/artist');

  api.addFile('pages/admin/artworks..');
  api.addComponent('pages/admin/artworks/artwork');

  api.addFile('pages/admin/websites..');
  api.addUnstyledComponent('pages/admin/websites/website');

  api.addFile('pages/admin/profiles..');
  api.addUnstyledComponent('pages/admin/profiles/profile');
  api.addUnstyledComponent('pages/admin/profiles/scripts');
  api.addServerFile('pages/admin/profiles/scripts-server');

  api.addUnstyledComponent('pages/admin/scripts..');
  api.addServerFile('pages/admin/scripts/methods-server/removeduplicatetwitterprofiles');

  // api.addUnstyledComponent('components/uploader/uploader');
});
