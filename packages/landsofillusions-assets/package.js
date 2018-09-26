Package.describe({
  name: 'retronator:landsofillusions-assets',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  'pngjs': '2.3.0',
  'bresenham-zingl': '0.1.1'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('edgee:slingshot');
  api.use('froatsnook:request');

  api.use('webapp');
  api.use('http');

  api.export('LandsOfIllusions');

  api.addFile('assets');

  api.addStyle('style/editor');
  api.addComponent('layout/layout');

  // Documents
  
  api.addFile('documents/image..');
  api.addFile('documents/image/methods');

  api.addFile('documents/palette..');
  api.addFile('documents/palette/methods');
  api.addFile('documents/palette/atari2600');
  api.addServerFile('documents/palette/subscriptions');
  api.addServerFile('documents/palette/migrations/0000-renameatari2600topixelartacademy');

  api.addServerFile('documents/palette/palettes-server/pixelartacademy');
  api.addServerFile('documents/palette/palettes-server/pico8');
  api.addServerFile('documents/palette/palettes-server/black');
  api.addServerFile('documents/palette/palettes-server/zxspectrum');

  api.addClientFile('documents/asset/asset-cache-client');
  api.addServerFile('documents/asset/asset-cache-server');
  api.addFile('documents/asset..');
  api.addFile('documents/asset/methods..');
  api.addFile('documents/asset/methods/history');
  api.addServerFile('documents/asset/subscriptions');

  api.addFile('documents/visualasset..');
  api.addFile('documents/visualasset/methods..');
  api.addFile('documents/visualasset/methods/references');

  api.addFile('documents/sprite..');
  api.addServerFile('documents/sprite/subscriptions');
  api.addServerFile('documents/sprite/server');
  api.addFile('documents/sprite/methods..');
  api.addFile('documents/sprite/methods/addpixel');
  api.addFile('documents/sprite/methods/removepixel');
  api.addFile('documents/sprite/methods/colorfill');
  api.addFile('documents/sprite/methods/replacepixels');

  api.addFile('documents/mesh..');
  api.addServerFile('documents/mesh/subscriptions');
  api.addFile('documents/mesh/methods..');

  api.addFile('documents/audio..');
  api.addServerFile('documents/audio/subscriptions');
  api.addFile('documents/audio/methods/addnode');
  api.addFile('documents/audio/methods/removenode');
  api.addFile('documents/audio/methods/updatenode');
  api.addFile('documents/audio/methods/updatenodeparameters');
  api.addFile('documents/audio/methods/updateconnections');

  // Upload

  api.addFile('upload..');
  api.addFile('upload/context..');
  api.addServerFile('upload/context/server');
  api.addClientFile('upload/context/client');
  
  // Tools

  api.addFile('tools/tools');
  api.addFile('tools/tool');

  // Components

  api.addFile('components/components');

  api.addUnstyledComponent('components/assetslist..');
  api.addUnstyledComponent('components/assetinfo..');
  api.addUnstyledComponent('components/navigator..');
  api.addUnstyledComponent('components/palette..');
  api.addUnstyledComponent('components/materials..');
  api.addUnstyledComponent('components/landmarks..');
  api.addUnstyledComponent('components/toolbox..');
  api.addUnstyledComponent('components/spriteimage..');
  api.addUnstyledComponent('components/camera..');

  api.addUnstyledComponent('components/references..');
  api.addUnstyledComponent('components/references/reference..');

  api.addUnstyledComponent('components/shadingsphere..');
  api.addFile('components/shadingsphere/normalpicker');

  api.addUnstyledComponent('components/pixelcanvas..');
  api.addFile('components/pixelcanvas/mouse');
  api.addFile('components/pixelcanvas/grid');
  api.addFile('components/pixelcanvas/cursor');
  api.addFile('components/pixelcanvas/camera');

  // Engine

  api.addFile('engine..');
  api.addFile('engine/sprite');

  api.addFile('engine/mesh..');
  api.addFile('engine/mesh/detectclusters');
  api.addFile('engine/mesh/computeedges');
  api.addFile('engine/mesh/cluster');
  api.addFile('engine/mesh/edge');

  api.addFile('engine/audio..');
  api.addFile('engine/audio/node');
  api.addFile('engine/audio/schedulednode');

  api.addFile('engine/audio/nodes/output');
  api.addFile('engine/audio/nodes/sound');

  api.addFile('engine/audio/nodes/player');
  api.addFile('engine/audio/nodes/constant');
  api.addFile('engine/audio/nodes/oscillator');

  api.addFile('engine/audio/nodes/gain');
  api.addFile('engine/audio/nodes/delay');
  api.addFile('engine/audio/nodes/biquadfilter');

  api.addFile('engine/audio/nodes/location');
  api.addFile('engine/audio/nodes/locationchange');
  api.addFile('engine/audio/nodes/number');
  api.addFile('engine/audio/nodes/sustainvalue');
  api.addFile('engine/audio/nodes/adsr');

  // Sprite editor

  api.addComponent('spriteeditor..');
  api.addFile('spriteeditor/tools..');
  api.addFile('spriteeditor/tools/pencil');
  api.addFile('spriteeditor/tools/eraser');
  api.addFile('spriteeditor/tools/colorpicker');
  api.addFile('spriteeditor/tools/colorfill');
  api.addFile('spriteeditor/tools/paintnormals');
  api.addFile('spriteeditor/tools/symmetry');
  api.addFile('spriteeditor/tools/undo');
  api.addFile('spriteeditor/tools/redo');

  // Mesh editor

  api.addComponent('mesheditor..');
  api.addUnstyledComponent('mesheditor/cameraangles..');
  api.addUnstyledComponent('mesheditor/meshcanvas..');
  api.addFile('mesheditor/meshcanvas/renderer');
  api.addFile('mesheditor/meshcanvas/scenemanager');
  api.addFile('mesheditor/meshcanvas/grid');
  api.addFile('mesheditor/meshcanvas/cameramanager');
  api.addFile('mesheditor/tools..');
  api.addFile('mesheditor/tools/pixelgrid');
  api.addFile('mesheditor/tools/planegrid');

  // Audio editor

  api.addComponent('audioeditor..');

  api.addComponent('audioeditor/audiocanvas..');
  api.addFile('audioeditor/audiocanvas/camera');
  api.addFile('audioeditor/audiocanvas/flowchart');
  api.addFile('audioeditor/audiocanvas/grid');
  api.addFile('audioeditor/audiocanvas/mouse');

  api.addComponent('audioeditor/node..');
  api.addComponent('audioeditor/node/parameter..');

  api.addComponent('audioeditor/node/nodes/sound..');
  api.addComponent('audioeditor/node/nodes/biquadfilter..');

  api.addComponent('audioeditor/nodelibrary..');

  api.addFile('audioeditor/tools..');
  api.addFile('audioeditor/tools/undo');
  api.addFile('audioeditor/tools/redo');

  api.addFile('audioeditor/worldcontrols/locationselect');
});
