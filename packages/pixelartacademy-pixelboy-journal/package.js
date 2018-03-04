Package.describe({
  name: 'retronator:pixelartacademy-pixelboy-journal',
  version: '0.2.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'quill': '1.3.5'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-pixelboy');

  api.export('PixelArtAcademy');

  api.addComponent('journal');

  api.addComponent('journalsview..');
  api.addFile('journalsview/renderer');
  api.addFile('journalsview/scenemanager');
  api.addFile('journalsview/journalmesh');

  api.addComponent('journalview..');
  api.addComponent('journalview/entries..');

  // Entry is loaded only on the client since it uses Quill that is not available on the server.
  api.addClientComponent('journalview/entry-client/entry');
  api.addClientFile('journalview/entry-client/object..');
  api.addClientComponent('journalview/entry-client/object/entrytime..');
  api.addClientComponent('journalview/entry-client/object/artwork..');

  api.addFile('journalview/journaldesign..');
  api.addComponent('journalview/journaldesign/traditional..');
});
