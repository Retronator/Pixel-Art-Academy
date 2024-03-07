Package.describe({
  name: 'retronator:pixelartacademy-pixeltosh',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:fatamorgana');
  api.use('retronator:pixelartacademy');

  api.export('PixelArtAcademy');

  api.addFile('pixeltosh');

  // HACK: We store programs in a folder called program since programs gets ignored by Meteor for legacy reasons.
  api.addFile('program/programs');
  api.addFile('program..');

  api.addComponent('computer..');
  api.addComponent('os..');
  api.addFile('os/interface..');
  api.addComponent('os/interface/cursor..');

  api.addFile('pages..');
  api.addComponent('pages/pixeltosh..');
});
