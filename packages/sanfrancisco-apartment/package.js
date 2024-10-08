Package.describe({
  name: 'retronator:sanfrancisco-apartment',
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
  api.use('retronator:sanfrancisco');
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy');
  api.use('retronator:pixelartacademy-items');

  api.export('SanFrancisco');

  api.addFile('apartment');

  // Locations

  api.addFile('entrance..');
  api.addFile('hallway..');

  api.addFile('studio..');
  api.addThing('studio/bed');
  api.addThing('studio/emailnotification');
  api.addFile('studio/kitchencabinet');

  api.addComponent('studio/computer..');
  api.addComponent('studio/computer/app..');
  api.addComponent('studio/computer/apps/desktop..');
  api.addComponent('studio/computer/apps/browser..');
  api.addComponent('studio/computer/apps/email..');
  api.addComponent('studio/computer/apps/game..');

});
