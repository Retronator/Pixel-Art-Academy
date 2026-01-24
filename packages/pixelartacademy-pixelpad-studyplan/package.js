Package.describe({
  name: 'retronator:pixelartacademy-pixelpad-studyplan',
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
  'bresenham-zingl': '0.2.0'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:pixelartacademy-pixelpad');
  api.use('retronator:illustrapedia');

  api.export('PixelArtAcademy');

  api.addComponent('studyplan');

  api.addFile('connectionpoint');
  api.addFile('goalhierarchy');
  api.addFile('goalnode');
  api.addFile('pathway');
  api.addFile('taskpoint');
  api.addFile('tilemap');
  api.addFile('tile');

  api.addFile('interfacemarking');
  api.addFile('instructions');

  api.addComponent('addgoal..');
  api.addComponent('goalsearch..');
  api.addComponent('goalinfo..');
  api.addComponent('taskinfo..');
  api.addStyledFile('bottompanel..');
  api.addComponent('activegoals..');
  api.addComponent('interests..');

  api.addComponent('blueprint..');
  api.addFile('blueprint/camera');
  api.addFile('blueprint/mouse');
  api.addComponent('blueprint/goal..');

  api.addComponent('blueprint/tilemap..');
  api.addFile('blueprint/tilemap/tilemap-buildings');
  api.addStyle('blueprint/tilemap/tilemap-buildings');
  api.addStyle('blueprint/tilemap/tilemap-terrain');
  api.addStyle('blueprint/tilemap/tilemap-pathways');
  api.addFile('blueprint/tilemap/tile');
});
