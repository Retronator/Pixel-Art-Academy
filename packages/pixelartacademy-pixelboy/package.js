Package.describe({
  name: 'retronator:pixelartacademy-pixelboy',
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
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartdatabase');

  api.export('PixelArtAcademy');

  api.addComponent('pixelboy');

  api.addComponent('os..');
  api.addStyledFile('os/app');

  api.addFile('apps..');

  api.addFile('apps/homescreen..');
  api.addFile('apps/calendar..');
  api.addFile('apps/calendar/provider');
  api.addFile('apps/journal..');
  api.addFile('apps/journal/checkin..');
  api.addFile('apps/journalscene..');
  api.addFile('apps/pico8..');
});
