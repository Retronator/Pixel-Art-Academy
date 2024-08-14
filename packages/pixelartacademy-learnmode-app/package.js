Package.describe({
  name: 'retronator:pixelartacademy-learnmode-app',
  version: '0.21.6',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.use('retronator:artificialengines');
  api.use('retronator:artificialengines-pages');

  api.use('retronator:retronator-accounts');
  api.use('retronator:retronator-store');

  api.use('retronator:landsofillusions');
  api.use('retronator:landsofillusions-assets');
  api.use('retronator:landsofillusions-ui');

  api.use('retronator:pixelartdatabase');

  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-practice');
  api.use('retronator:pixelartacademy-learning');
  api.use('retronator:pixelartacademy-studyguide');
  api.use('retronator:pixelartacademy-challenges');
  api.use('retronator:pixelartacademy-tutorials');
  api.use('retronator:pixelartacademy-pico8');
  api.use('retronator:pixelartacademy-pico8-snake');
  api.use('retronator:pixelartacademy-pixeltosh');
  api.use('retronator:pixelartacademy-pixeltosh-pinball');

  api.use('retronator:pixelartacademy-pixelpad');
  api.use('retronator:pixelartacademy-pixelpad-pico8');
  api.use('retronator:pixelartacademy-pixelpad-pixeltosh');
  api.use('retronator:pixelartacademy-pixelpad-drawing');
  api.use('retronator:pixelartacademy-pixelpad-studyplan');
  api.use('retronator:pixelartacademy-pixelpad-todo');
  api.use('retronator:pixelartacademy-pixelpad-instructions');

  api.use('retronator:pixelartacademy-learnmode');
  api.use('retronator:pixelartacademy-learnmode-intro');
  api.use('retronator:pixelartacademy-learnmode-pixelartfundamentals');

  api.export('PixelArtAcademy');

  api.addComponent('app');

  api.addFile('layouts..');
  api.addUnstyledComponent('layouts/publicaccess..');

  api.addFile('adventure..');

});
