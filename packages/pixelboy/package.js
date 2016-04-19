Package.describe({
  name: 'pixelboy',
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
  api.use('adventure');

  api.export('PixelArtAcademy');

  api.addFiles('pixelboy.coffee');

  api.addFiles('os/os.coffee');
  api.addFiles('os/os.html');

  api.addFiles('os/app.coffee');

  api.addFiles('apps/apps.coffee');

  api.addFiles('apps/calendar/calendar.html');
  api.addFiles('apps/calendar/calendar.styl');
  api.addFiles('apps/calendar/calendar.coffee');
  api.addFiles('apps/calendar/provider.coffee');

  api.addFiles('apps/journal/journal.html');
  api.addFiles('apps/journal/journal.styl');
  api.addFiles('apps/journal/journal.coffee');

  api.addFiles('apps/journal/checkin/checkin.html');
  api.addFiles('apps/journal/checkin/checkin.styl');
  api.addFiles('apps/journal/checkin/checkin.coffee');

  api.addFiles('components/components.coffee');

  api.addFiles('components/item/item.coffee');
  api.addFiles('components/item/item.html');
  api.addFiles('components/item/item.styl');

  api.addFiles('components/appswitcher/appswitcher.html');
  api.addFiles('components/appswitcher/appswitcher.styl');
  api.addFiles('components/appswitcher/appswitcher.coffee');
});
