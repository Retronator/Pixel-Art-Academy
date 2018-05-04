Package.describe({
  name: 'retronator:pixelartacademy',
  version: '0.2.0',
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
  api.imply('retronator:landsofillusions');

  api.export('PixelArtAcademy');

  api.addFile('pixelartacademy');

  api.addFile('adventure..');

  // Layouts

  api.addFile('layouts..');
  api.addFile('layouts/adminaccess..');

  api.addServerFile('character/methods');

  api.addThing('character/personupdates');
  api.addFile('character/characterupdateshelper');
  
  api.addFile('groups..');
  api.addFile('groups/hangoutgroup');
});
