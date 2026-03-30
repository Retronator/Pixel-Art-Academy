Package.describe({
  name: 'retronator:pixelartacademy',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'onnxruntime-web': '1.16.3',
  'bresenham-zingl': '0.2.0'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');
  api.use('retronator:landsofillusions-ui');
  api.imply('retronator:landsofillusions-ui');

  api.export('PixelArtAcademy');

  api.addFile('pixelartacademy');

  api.addFile('imageclassification..');
  api.addFile('imageclassification/simpleclassifier');

  api.addFile('pages..');
  api.addComponent('pages/imageclassification..');

  api.addFile('adventure..');
  api.addFile('chapter..');
});
