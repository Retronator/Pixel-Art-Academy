Package.describe({
  name: 'retronator:pixelartacademy-pixeltosh-pinball',
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
  api.use('retronator:pixelartacademy-pixeltosh');

  api.export('PixelArtAcademy');

  api.addFile('pinball');

  api.addFile('interface..');
  api.addComponent('interface/playfield..');
  api.addComponent('interface/backbox..');
  api.addComponent('interface/instructions..');
});
