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
  'delaunator': '3.0.2',
  'bresenham-zingl': '0.1.1',
  'pako': '1.0.8'
});

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');
  api.use('retronator:fatamorgana');
  api.use('edgee:slingshot');
  api.use('froatsnook:request');

  api.use('webapp');
  api.use('http');

  api.export('LandsOfIllusions');

  api.addFile('assets');

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
  api.addFile('documents/sprite/methods/transformpixels');
  api.addFile('documents/sprite/methods/layers');

  api.addFile('documents/mesh..');
  api.addFile('documents/mesh/valuefield');
  api.addFile('documents/mesh/arrayfield');
  api.addFile('documents/mesh/cameraangle');
  api.addFile('documents/mesh/object');
  api.addFile('documents/mesh/layer');
  api.addFile('documents/mesh/picture');

  api.addFile('documents/mesh/map..');
  api.addFile('documents/mesh/map/flags');
  api.addFile('documents/mesh/map/materialindex');
  api.addFile('documents/mesh/map/palettecolor');
  api.addFile('documents/mesh/map/directcolor');
  api.addFile('documents/mesh/map/alpha');
  api.addFile('documents/mesh/map/normal');

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

  // Components

  api.addFile('components/components');

  api.addUnstyledComponent('components/assetslist..');
  api.addUnstyledComponent('components/assetinfo..');
  api.addUnstyledComponent('components/navigator..');
  api.addUnstyledComponent('components/palette..');
  api.addUnstyledComponent('components/spriteimage..');

  api.addUnstyledComponent('components/references..');
  api.addUnstyledComponent('components/references/reference..');

  api.addUnstyledComponent('components/pixelcanvas..');
  api.addFile('components/pixelcanvas/mouse');
  api.addFile('components/pixelcanvas/grid');
  api.addFile('components/pixelcanvas/cursor');
  api.addFile('components/pixelcanvas/camera');

  api.addFile('components/tool..');

  // Engine

  api.addFile('engine..');

  api.addFile('engine/sprite..');

  api.addFile('engine/mesh..');
  api.addFile('engine/mesh/object..');
  api.addFile('engine/mesh/object/cluster');
  api.addFile('engine/mesh/object/edge');
  api.addFile('engine/mesh/object/detectclusters');
  api.addFile('engine/mesh/object/computeedges');
  api.addFile('engine/mesh/object/computeclusterplanes');
  api.addFile('engine/mesh/object/projectclusterpoints');
  api.addFile('engine/mesh/object/computeclustermeshes');
  api.addFile('engine/mesh/object/rampmaterial');

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
  
  // Editors
  
  api.addComponent('editor..');
  api.addStyle('editor/editor-cursors');
  api.addStyle('editor/editor-fatamorgana');

  api.addFile('editor/tools..');
  api.addFile('editor/tools/tool');
  api.addFile('editor/tools/arrow');

  api.addFile('editor/actions..');
  api.addFile('editor/actions/assetaction');
  api.addFile('editor/actions/showaction');
  api.addFile('editor/actions/showhelperaction');
  api.addFile('editor/actions/history');
  api.addFile('editor/actions/new');
  api.addFile('editor/actions/open');
  api.addFile('editor/actions/delete');
  api.addFile('editor/actions/duplicate');
  api.addFile('editor/actions/clear');
  api.addFile('editor/actions/close');

  api.addFile('editor/helpers..');
  api.addFile('editor/helpers/drawcomponent');

  api.addComponent('editor/assetinfo..');
  api.addComponent('editor/assetopendialog..');
  api.addComponent('editor/landmarks..');
  api.addComponent('editor/window..');
  api.addComponent('editor/materials..');

  api.addComponent('editor/filemanager..');

  api.addComponent('editor/filemanager/directory..');
  api.addFile('editor/filemanager/directory/folder');
  api.addFile('editor/filemanager/directory/newfolder');

  api.addFile('editor/filemanager/previews..');
  api.addComponent('editor/filemanager/previews/sprite..');

  // Sprite editor

  api.addFile('spriteeditor..');
  api.addFile('spriteeditor/spriteloader');

  api.addFile('spriteeditor/tools..');
  api.addFile('spriteeditor/tools/tool');
  api.addFile('spriteeditor/tools/stroke');
  api.addFile('spriteeditor/tools/pencil');
  api.addFile('spriteeditor/tools/eraser');
  api.addFile('spriteeditor/tools/colorpicker');
  api.addFile('spriteeditor/tools/colorfill');
  api.addFile('spriteeditor/tools/translate');
  
  api.addFile('spriteeditor/actions..');
  api.addFile('spriteeditor/actions/paintnormals');
  api.addFile('spriteeditor/actions/symmetry');
  api.addFile('spriteeditor/actions/fliphorizontal');
  api.addFile('spriteeditor/actions/zoom');
  api.addFile('spriteeditor/actions/showpixelgrid');
  api.addFile('spriteeditor/actions/showlandmarks');
  api.addFile('spriteeditor/actions/showsafearea');
  api.addFile('spriteeditor/actions/brushsize');

  api.addFile('spriteeditor/helpers..');
  api.addFile('spriteeditor/helpers/zoomlevels');
  api.addFile('spriteeditor/helpers/landmarks');
  api.addFile('spriteeditor/helpers/paint');
  api.addFile('spriteeditor/helpers/lightdirection');
  api.addFile('spriteeditor/helpers/safearea');
  api.addFile('spriteeditor/helpers/brush');

  api.addComponent('spriteeditor/navigator..');
  api.addComponent('spriteeditor/palette..');
  api.addComponent('spriteeditor/layers..');
  api.addUnstyledComponent('spriteeditor/thumbnail..');

  api.addComponent('spriteeditor/pixelcanvas..');
  api.addFile('spriteeditor/pixelcanvas/mouse');
  api.addFile('spriteeditor/pixelcanvas/cursor');
  api.addFile('spriteeditor/pixelcanvas/camera');
  api.addFile('spriteeditor/pixelcanvas/landmarks');
  api.addFile('spriteeditor/pixelcanvas/pixelgrid');
  api.addFile('spriteeditor/pixelcanvas/operationpreview');
  api.addFile('spriteeditor/pixelcanvas/toolinfo');

  api.addComponent('spriteeditor/shadingsphere..');
  api.addFile('spriteeditor/shadingsphere/normalpicker');

  // Mesh editor

  api.addFile('mesheditor..');
  api.addFile('mesheditor/meshloader');

  api.addFile('mesheditor/tools..');
  api.addFile('mesheditor/tools/tool');
  api.addFile('mesheditor/tools/movecamera');
  api.addFile('mesheditor/tools/clusterpicker');
  api.addFile('mesheditor/tools/pencil');
  api.addFile('mesheditor/tools/eraser');
  api.addFile('mesheditor/tools/colorfill');

  api.addFile('mesheditor/actions..');
  api.addFile('mesheditor/actions/debugmode');
  api.addFile('mesheditor/actions/showedges');
  api.addFile('mesheditor/actions/showhorizon');
  api.addFile('mesheditor/actions/showpixelrender');
  api.addFile('mesheditor/actions/showplanegrid');
  api.addFile('mesheditor/actions/showsourceimage');
  api.addFile('mesheditor/actions/history');
  api.addFile('mesheditor/actions/save');

  api.addFile('mesheditor/helpers..');
  api.addFile('mesheditor/helpers/currentcluster');
  api.addFile('mesheditor/helpers/scene');
  api.addFile('mesheditor/helpers/selection');

  api.addUnstyledComponent('mesheditor/camera..');
  api.addComponent('mesheditor/cameraangles..');
  api.addComponent('mesheditor/objects..');
  api.addComponent('mesheditor/layers..');

  api.addComponent('mesheditor/cameraangle..');
  api.addUnstyledComponent('mesheditor/cameraangle/selectspritedialog..');

  api.addComponent('mesheditor/meshcanvas..');
  api.addFile('mesheditor/meshcanvas/edges');
  api.addFile('mesheditor/meshcanvas/horizon');
  api.addFile('mesheditor/meshcanvas/planegrid');

  api.addFile('mesheditor/meshcanvas/renderer..');
  api.addFile('mesheditor/meshcanvas/renderer/cameramanager');
  api.addFile('mesheditor/meshcanvas/renderer/pixelrender');

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
