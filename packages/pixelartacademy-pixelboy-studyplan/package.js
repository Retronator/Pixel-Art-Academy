Package.describe({
  name: 'retronator:pixelartacademy-pixelboy-studyplan',
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
  'bresenham-zingl': '0.1.1'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-pixelboy');
  api.use('retronator:illustrapedia');
  api.use('retronator:pixelartacademy-season1-episode1');

  api.export('PixelArtAcademy');

  api.addComponent('studyplan');

  api.addComponent('goal..');
  api.addComponent('goal/task');
  api.addFile('goal/tasksmapconnections');

  api.addComponent('goalsearch..');

  api.addComponent('blueprint..');
  api.addFile('blueprint/flowchart');
  api.addFile('blueprint/camera');
  api.addFile('blueprint/mouse');
  api.addFile('blueprint/grid');
});
