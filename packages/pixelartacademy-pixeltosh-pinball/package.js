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
  api.use('retronator:pixelartacademy-learnmode');
  api.use('retronator:pixelartacademy-pixeltosh');

  api.export('PixelArtAcademy');

  api.addFile('pinball');
  api.addFile('assets');
  api.addFile('project');
  api.addFile('project-startend');
  api.addFile('instructions');

  api.addFile('scenemanager');
  api.addFile('cameramanager');
  api.addFile('renderermanager');
  api.addFile('physicsmanager');
  api.addFile('inputmanager');
  api.addFile('gamemanager');
  api.addFile('editormanager');
  api.addFile('editormanager-startdrag');
  api.addFile('editormanager-startrotate');
  api.addFile('mouse');
  api.addFile('ball');

  api.addFile('part..');
  api.addFile('part/avatar..');
  api.addFile('part/avatar/renderobject');
  api.addFile('part/avatar/renderobject-createextrusiongeometry');
  api.addFile('part/avatar/physicsobject');
  api.addFile('part/avatar/shape');
  api.addFile('part/avatar/sphere');
  api.addFile('part/avatar/box');
  api.addFile('part/avatar/cylinder');
  api.addFile('part/avatar/trianglemesh');
  api.addFile('part/avatar/extrusion');
  api.addFile('part/avatar/taperedextrusion');
  api.addFile('part/avatar/convexextrusion');
  api.addFile('part/avatar/depression');
  api.addFile('part/avatar/silhouette');

  api.addFile('parts..');
  api.addFile('parts/ballspawner');
  api.addFile('parts/walls');
  api.addFile('parts/wireballguides');
  api.addFile('parts/pins');
  api.addFile('parts/plunger');
  api.addFile('parts/flipper');
  api.addFile('parts/hole');
  api.addFile('parts/gobblehole');
  api.addFile('parts/playfield');
  api.addFile('parts/balltrough');
  api.addFile('parts/pin');
  api.addFile('parts/dynamicpart');
  api.addFile('parts/spinningtarget');
  api.addFile('parts/gate');
  api.addFile('parts/bumper');

  api.addStyledFile('interface..');
  api.addComponent('interface/playfield..');
  api.addFile('interface/playfield/playfield-polygondebug');
  api.addComponent('interface/backbox..');
  api.addComponent('interface/instructions..');
  api.addComponent('interface/parts..');
  api.addComponent('interface/settings..');
  api.addComponent('interface/settings/number..');
  api.addComponent('interface/settings/boolean..');

  api.addFile('interface/actions..');
  api.addFile('interface/actions/action');
  api.addFile('interface/actions/camera');
  api.addFile('interface/actions/toggledebugphysics');
  api.addFile('interface/actions/toggleslowmotion');
  api.addFile('interface/actions/toggledisplaywalls');
  api.addFile('interface/actions/modes');
  api.addFile('interface/actions/reset');
  api.addFile('interface/actions/flip');
  api.addFile('interface/actions/rotate');
  api.addFile('interface/actions/delete');
});
