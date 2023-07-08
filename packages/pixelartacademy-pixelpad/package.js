Package.describe({
  name: 'retronator:pixelartacademy-pixelpad',
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
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-pico8');

  api.export('PixelArtAcademy');

  api.addComponent('pixelpad');
  api.addFile('app');
  api.addFile('system');

  api.addFile('components..');

  api.addComponent('components/shortcutstable..');

  api.addFile('components/mixins..');
  api.addFile('components/mixins/pageturner');

  api.addComponent('os..');

  api.addFile('apps..');
  api.addComponent('apps/homescreen..');

  api.addFile('systems..');
});
