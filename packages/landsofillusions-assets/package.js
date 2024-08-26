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
  'fast-png': '4.0.1',
  'delaunator': '3.0.2',
  'bresenham-zingl': '0.1.1',
  'pako': '1.0.8',
  'ml-regression-theil-sen': '1.0.0',
  'canvas': '2.11.2'
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
  api.addFile('documents/image/subscriptions');
  api.addServerFile('documents/image/image-server-databasecontent');

  api.addFile('documents/palette..');
  api.addServerFile('documents/palette/palette-server-databasecontent');
  api.addServerFile('documents/palette/server');
  api.addFile('documents/palette/methods');
  api.addFile('documents/palette/atari2600');
  api.addFile('documents/palette/subscriptions');
  api.addServerFile('documents/palette/migrations/0000-renameatari2600topixelartacademy');

  api.addServerFile('documents/palette/palettes-server/pixelartacademy');
  api.addServerFile('documents/palette/palettes-server/pico8');
  api.addServerFile('documents/palette/palettes-server/black');
  api.addServerFile('documents/palette/palettes-server/zxspectrum');
  api.addServerFile('documents/palette/palettes-server/macintosh');

  api.addClientFile('documents/asset/asset-cache-client');
  api.addServerFile('documents/asset/asset-cache-server');
  api.addFile('documents/asset/asset-databasecontent');
  api.addFile('documents/asset..');
  api.addFile('documents/asset/methods..');
  api.addFile('documents/asset/methods/history');
  api.addServerFile('documents/asset/subscriptions');

  api.addFile('documents/visualasset..');
  api.addFile('documents/visualasset/methods..');
  api.addFile('documents/visualasset/methods/references');
  api.addFile('documents/visualasset/methods/environments');
  api.addServerFile('documents/visualasset/subscriptions');
  api.addFile('documents/visualasset/actions..');
  api.addFile('documents/visualasset/actions/addreferencebyurl');
  api.addFile('documents/visualasset/actions/updatereference');
  api.addFile('documents/visualasset/actions/reorderreferencetotop');
  api.addFile('documents/visualasset/actions/updateproperty');
  api.addFile('documents/visualasset/operations..');
  api.addFile('documents/visualasset/operations/addreference');
  api.addFile('documents/visualasset/operations/updatereference');
  api.addFile('documents/visualasset/operations/removereference');
  api.addFile('documents/visualasset/operations/updateproperty');

  api.addFile('documents/sprite..');
  api.addFile('documents/sprite/rot8');
  api.addFile('documents/sprite/mip');
  api.addServerFile('documents/sprite/subscriptions');
  api.addServerFile('documents/sprite/server');
  api.addFile('documents/sprite/methods..');
  api.addFile('documents/sprite/methods/addpixels');
  api.addFile('documents/sprite/methods/removepixels');
  api.addFile('documents/sprite/methods/smoothpixels');
  api.addFile('documents/sprite/methods/colorfill');
  api.addFile('documents/sprite/methods/replacepixels');
  api.addFile('documents/sprite/methods/transformpixels');
  api.addFile('documents/sprite/methods/layers');
  api.addFile('documents/sprite/methods/resize');

  api.addFile('documents/bitmap..');
  api.addFile('documents/bitmap/area');
  api.addFile('documents/bitmap/layer');
  api.addFile('documents/bitmap/layergroup');
  api.addFile('documents/bitmap/pixelformat');

  api.addFile('documents/bitmap/attribute..');
  api.addFile('documents/bitmap/attribute/alpha');
  api.addFile('documents/bitmap/attribute/clusterid');
  api.addFile('documents/bitmap/attribute/directcolor');
  api.addFile('documents/bitmap/attribute/flags');
  api.addFile('documents/bitmap/attribute/materialindex');
  api.addFile('documents/bitmap/attribute/normal');
  api.addFile('documents/bitmap/attribute/operationmask');
  api.addFile('documents/bitmap/attribute/palettecolor');

  api.addFile('documents/bitmap/actions..');
  api.addFile('documents/bitmap/actions/addlayer');
  api.addFile('documents/bitmap/actions/stroke');
  api.addFile('documents/bitmap/actions/colorfill');
  api.addFile('documents/bitmap/actions/changebounds');

  api.addFile('documents/bitmap/operations..');
  api.addFile('documents/bitmap/operations/addlayer');
  api.addFile('documents/bitmap/operations/removelayer');
  api.addFile('documents/bitmap/operations/changepixels');
  api.addFile('documents/bitmap/operations/changebounds');

  api.addFile('documents/mesh..');
  api.addFile('documents/mesh/methods');
  api.addFile('documents/mesh/valuefield');
  api.addFile('documents/mesh/arrayfield');
  api.addFile('documents/mesh/mapfield');
  api.addFile('documents/mesh/cameraangle');
  api.addFile('documents/mesh/material');

  api.addFile('documents/mesh/object..');

  api.addFile('documents/mesh/object/layer..');
  api.addFile('documents/mesh/object/layer/cluster');

  api.addFile('documents/mesh/object/layer/picture..');
  api.addFile('documents/mesh/object/layer/picture/picture-clearpixels');
  api.addFile('documents/mesh/object/layer/picture/picture-setpixels');
  api.addFile('documents/mesh/object/layer/picture/picture-recomputeclusters');
  api.addFile('documents/mesh/object/layer/picture/picture-detectclusters');
  api.addFile('documents/mesh/object/layer/picture/picture-matchdetectedclusters');
  api.addFile('documents/mesh/object/layer/picture/cluster');

  api.addFile('documents/mesh/object/layer/picture/map..');
  api.addFile('documents/mesh/object/layer/picture/map/flags');
  api.addFile('documents/mesh/object/layer/picture/map/materialindex');
  api.addFile('documents/mesh/object/layer/picture/map/palettecolor');
  api.addFile('documents/mesh/object/layer/picture/map/directcolor');
  api.addFile('documents/mesh/object/layer/picture/map/alpha');
  api.addFile('documents/mesh/object/layer/picture/map/normal');
  api.addFile('documents/mesh/object/layer/picture/map/clusterid');

  api.addFile('documents/mesh/object/solver..');
  api.addFile('documents/mesh/object/solver/polyhedron..');
  api.addFile('documents/mesh/object/solver/polyhedron/polyhedron-computeclustermeshes');
  api.addFile('documents/mesh/object/solver/polyhedron/polyhedron-computeclusterplanes');
  api.addFile('documents/mesh/object/solver/polyhedron/polyhedron-computeedges');
  api.addFile('documents/mesh/object/solver/polyhedron/polyhedron-projectclusterpoints');
  api.addFile('documents/mesh/object/solver/polyhedron/cluster');
  api.addFile('documents/mesh/object/solver/polyhedron/clusterplane');
  api.addFile('documents/mesh/object/solver/polyhedron/edge');

  api.addFile('documents/audio..');
  api.addFile('documents/audio/audio-getpreviewimage');
  api.addFile('documents/audio/namespace');
  api.addFile('documents/audio/subscriptions');
  api.addFile('documents/audio/methods/addnode');
  api.addFile('documents/audio/methods/removenode');
  api.addFile('documents/audio/methods/updatenode');
  api.addFile('documents/audio/methods/updatenodeparameters');
  api.addFile('documents/audio/methods/updateconnections');

  api.addServerFile('documents/asset/migrations/0000-moveauthorstoprofileid');

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
  api.addUnstyledComponent('components/bitmapimage..');
  api.addUnstyledComponent('components/toolbox..');

  api.addUnstyledComponent('components/references..');
  api.addUnstyledComponent('components/references/reference..');

  api.addUnstyledComponent('components/pixelcanvas..');
  api.addFile('components/pixelcanvas/mouse');
  api.addFile('components/pixelcanvas/grid');
  api.addFile('components/pixelcanvas/cursor');
  api.addFile('components/pixelcanvas/camera');

  api.addFile('components/tools..');
  api.addFile('components/tools/tool');
  api.addFile('components/tools/pencil');
  api.addFile('components/tools/harderaser');
  api.addFile('components/tools/colorfill');
  api.addFile('components/tools/colorpicker');
  api.addFile('components/tools/undo');
  api.addFile('components/tools/redo');

  // Engine

  api.addFile('engine..');

  api.addFile('engine/pixelimage..');
  api.addFile('engine/pixelimage/sprite');
  api.addFile('engine/pixelimage/bitmap');

  api.addFile('engine/mesh..');
  api.addFile('engine/mesh/object');
  api.addFile('engine/mesh/layer');
  api.addFile('engine/mesh/cluster');

  api.addFile('engine/audio..');
  api.addFile('engine/audio/nodes..');
  api.addFile('engine/audio/nodes/location');
  api.addFile('engine/audio/nodes/locationchange');
  api.addFile('engine/audio/nodes/modaldialog');

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
  api.addFile('editor/actions/persisteditorsinterface');
  api.addFile('editor/actions/resetinterface');
  api.addFile('editor/actions/export');
  api.addFile('editor/actions/import');
  api.addFile('editor/actions/exposure');

  api.addFile('editor/helpers..');
  api.addFile('editor/helpers/drawcomponent');
  api.addFile('editor/helpers/exposurevalue');

  api.addComponent('editor/assetinfo..');
  api.addComponent('editor/dialog..');
  api.addComponent('editor/assetopendialog..');
  api.addComponent('editor/window..');
  api.addComponent('editor/materials..');
  api.addComponent('editor/navigator..');
  api.addComponent('editor/environments..');

  api.addComponent('editor/references..');
  api.addComponent('editor/references/displaycomponent..');
  api.addComponent('editor/references/displaycomponent/reference..');

  api.addComponent('editor/filemanager..');

  api.addComponent('editor/filemanager/directory..');
  api.addFile('editor/filemanager/directory/folder');

  api.addFile('editor/filemanager/directory/actions/newfolder');
  api.addFile('editor/filemanager/directory/actions/createrot8');
  api.addFile('editor/filemanager/directory/actions/duplicate');
  api.addFile('editor/filemanager/directory/actions/delete');
  api.addFile('editor/filemanager/directory/actions/emptytrash');
  api.addFile('editor/filemanager/directory/actions/fliphorizontal');
  api.addFile('editor/filemanager/directory/actions/createmip');

  api.addFile('editor/filemanager/previews..');
  api.addComponent('editor/filemanager/previews/sprite..');
  api.addFile('editor/filemanager/previews/mesh..');
  api.addComponent('editor/filemanager/previews/audio..');
  api.addComponent('editor/filemanager/previews/sound..');

  // Sprite editor

  api.addFile('spriteeditor..');
  api.addFile('spriteeditor/spriteloader');
  api.addFile('spriteeditor/rot8loader');
  api.addFile('spriteeditor/miploader');

  api.addFile('spriteeditor/tools..');
  api.addFile('spriteeditor/tools/tool');
  api.addFile('spriteeditor/tools/aliasedstroke');
  api.addFile('spriteeditor/tools/pencil');
  api.addFile('spriteeditor/tools/harderaser');
  api.addFile('spriteeditor/tools/smooth');
  api.addFile('spriteeditor/tools/colorpicker');
  api.addFile('spriteeditor/tools/colorfill');
  api.addFile('spriteeditor/tools/translate');

  api.addFile('spriteeditor/actions..');
  api.addFile('spriteeditor/actions/paintnormals');
  api.addFile('spriteeditor/actions/ignorenormals');
  api.addFile('spriteeditor/actions/symmetry');
  api.addFile('spriteeditor/actions/fliphorizontal');
  api.addFile('spriteeditor/actions/zoom');
  api.addFile('spriteeditor/actions/showpixelgrid');
  api.addFile('spriteeditor/actions/showlandmarks');
  api.addFile('spriteeditor/actions/showsafearea');
  api.addFile('spriteeditor/actions/brushsize');
  api.addFile('spriteeditor/actions/rot8');
  api.addFile('spriteeditor/actions/resize');
  api.addFile('spriteeditor/actions/generatemipmaps');
  api.addFile('spriteeditor/actions/showshading');

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
  api.addComponent('spriteeditor/landmarks..');
  api.addComponent('spriteeditor/resizedialog..');

  api.addComponent('spriteeditor/pixelcanvas..');
  api.addFile('spriteeditor/pixelcanvas/pointer');
  api.addFile('spriteeditor/pixelcanvas/cursor');
  api.addFile('spriteeditor/pixelcanvas/camera');
  api.addFile('spriteeditor/pixelcanvas/landmarks');
  api.addFile('spriteeditor/pixelcanvas/pixelgrid');
  api.addFile('spriteeditor/pixelcanvas/operationpreview');

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
  api.addFile('mesheditor/tools/harderaser');
  api.addFile('mesheditor/tools/colorfill');
  api.addFile('mesheditor/tools/translate');

  api.addFile('mesheditor/actions..');
  api.addFile('mesheditor/actions/debugmode');
  api.addFile('mesheditor/actions/showedges');
  api.addFile('mesheditor/actions/showhorizon');
  api.addFile('mesheditor/actions/showpixelrender');
  api.addFile('mesheditor/actions/showplanegrid');
  api.addFile('mesheditor/actions/showsourceimage');
  api.addFile('mesheditor/actions/history');
  api.addFile('mesheditor/actions/save');
  api.addFile('mesheditor/actions/shadowsenabled');
  api.addFile('mesheditor/actions/recomputemesh');
  api.addFile('mesheditor/actions/smoothshadingenabled');
  api.addFile('mesheditor/actions/resetcamera');
  api.addFile('mesheditor/actions/pbrenabled');

  api.addFile('mesheditor/helpers..');
  api.addFile('mesheditor/helpers/currentcluster');
  api.addFile('mesheditor/helpers/scene');
  api.addFile('mesheditor/helpers/selection');
  api.addFile('mesheditor/helpers/shadowsenabled');
  api.addFile('mesheditor/helpers/landmarks');
  api.addFile('mesheditor/helpers/smoothshadingenabled');
  api.addFile('mesheditor/helpers/pbrenabled');


  api.addUnstyledComponent('mesheditor/navigator..');
  api.addUnstyledComponent('mesheditor/camera..');
  api.addUnstyledComponent('mesheditor/matrix..');
  api.addComponent('mesheditor/cameraangles..');
  api.addComponent('mesheditor/objects..');
  api.addComponent('mesheditor/layers..');
  api.addComponent('mesheditor/landmarks..');
  api.addComponent('mesheditor/materials..');
  api.addUnstyledComponent('mesheditor/thumbnail..');
  api.addFile('mesheditor/thumbnail/picture');
  api.addFile('mesheditor/thumbnail/pictures');
  api.addComponent('mesheditor/cameraangle..');
  api.addComponent('mesheditor/cluster..');
  api.addComponent('mesheditor/materialdialog..');
  api.addUnstyledComponent('mesheditor/spriteselectdialog..');
  api.addUnstyledComponent('mesheditor/texturemappingmatrix..');

  api.addComponent('mesheditor/meshcanvas..');
  api.addFile('mesheditor/meshcanvas/edges');
  api.addFile('mesheditor/meshcanvas/horizon');
  api.addFile('mesheditor/meshcanvas/planegrid');
  api.addFile('mesheditor/meshcanvas/debugray');

  api.addFile('mesheditor/meshcanvas/renderer..');
  api.addFile('mesheditor/meshcanvas/renderer/cameramanager');
  api.addFile('mesheditor/meshcanvas/renderer/pixelrender');
  api.addFile('mesheditor/meshcanvas/renderer/debugcluster');

  api.addFile('mesheditor/meshcanvas/renderer/sourceimage..');
  api.addFile('mesheditor/meshcanvas/renderer/sourceimage/material');

  // Audio editor

  api.addFile('audioeditor..');
  api.addFile('audioeditor/audioloader');
  api.addFile('audioeditor/publicdirectory');
  api.addServerFile('audioeditor/publicdirectory-server');

  api.addComponent('audioeditor/adventureview..');
  api.addComponent('audioeditor/adventureview/adventure..');

  api.addFile('audioeditor/adventureview/controls/locationselect');
  api.addFile('audioeditor/adventureview/controls/modaldialogselect');

  api.addComponent('audioeditor/audiocanvas..');
  api.addFile('audioeditor/audiocanvas/flowchart');
  api.addFile('audioeditor/audiocanvas/grid');
  api.addFile('audioeditor/audiocanvas/mouse');
  api.addFile('audioeditor/audiocanvas/camera');

  api.addComponent('audioeditor/node..');
  api.addComponent('audioeditor/node/parameter..');

  api.addComponent('audioeditor/node/nodes/sound..');
  api.addComponent('audioeditor/node/nodes/biquadfilter..');
  api.addComponent('audioeditor/node/nodes/variable..');

  api.addUnstyledComponent('audioeditor/navigator..');
  api.addComponent('audioeditor/nodelibrary..');

  api.addFile('audioeditor/tools..');
  api.addFile('audioeditor/tools/undo');
  api.addFile('audioeditor/tools/redo');

  api.addFile('audioeditor/actions..');
  api.addFile('audioeditor/actions/duplicatenode');
  api.addFile('audioeditor/actions/deletenode');

  api.addUnstyledComponent('audioeditor/soundselectdialog..');
});
