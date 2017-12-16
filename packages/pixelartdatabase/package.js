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
  'webshot': '0.18.0',
  's3-streaming-upload': '0.2.3'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');

  api.export('PixelArtDatabase');

  api.addFile('pixelartdatabase');

  // Artist

  api.addFile('artist/artist');
  api.addServerFile('artist/server');
  api.addFile('artist/methods');
  api.addServerFile('artist/subscriptions');

  // Artwork

  api.addFile('artwork/artwork');
  api.addFile('artwork/methods');
  api.addServerFile('artwork/subscriptions');
  api.addServerFile('artwork/migrations/0000-converttohttps');

  // Character

  api.addFile('character/character');

  // Profile

  api.addFile('profile/profile');
  api.addServerFile('profile/server');
  api.addServerFile('profile/subscriptions');

  api.addServerFile('profile/providers-server/providers');
  api.addServerFile('profile/providers-server/twitter');

  // Website

  api.addFile('website/website');
  api.addServerFile('website/methods-server');
  api.addServerFile('website/renderpreview-server');
  api.addServerFile('website/subscriptions');

  // Components

  api.addFile('components/components');

  api.addUnstyledComponent('components/stream/stream');

  // Pages

  api.addFile('pages/pages');

  // Admin

  api.addUnstyledComponent('pages/admin/admin');

  api.addFile('pages/admin/artists/artists');
  api.addUnstyledComponent('pages/admin/artists/artist');

  api.addFile('pages/admin/artworks/artworks');
  api.addComponent('pages/admin/artworks/artwork');

  api.addFile('pages/admin/websites/websites');
  api.addUnstyledComponent('pages/admin/websites/website');

  // api.addUnstyledComponent('components/uploader/uploader');
});
