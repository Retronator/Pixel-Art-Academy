Package.describe({
  name: 'pixelartacademy',
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
  api.use('kadira:flow-router');
  api.use('retronator:landsofillusions');
  api.use('alanning:roles');

  api.imply('retronator:landsofillusions');

  api.export('PixelArtAcademy');

  api.addFiles('pixelartacademy.html');
  api.addFiles('pixelartacademy.coffee');

  api.addFiles('pages/pages.coffee');

  api.addFiles('pages/home/home.html');
  api.addFiles('pages/home/home.coffee');

  api.addFiles('pages/calendar/calendar.html');
  api.addFiles('pages/calendar/calendar.coffee');
});
