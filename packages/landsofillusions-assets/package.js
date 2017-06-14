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

Package.onUse(function(api) {
  api.use('retronator:landsofillusions');

  api.export('LandsOfIllusions');

  api.addFile('assets');

  api.addStyle('style/editor');
  api.addComponent('layout/layout');

  // Documents

  api.addFile('documents/palette/palette');
  api.addFile('documents/palette/methods');
  api.addFile('documents/palette/atari2600');
  api.addServerFile('documents/palette/subscriptions');

  api.addFile('documents/visualasset/visualasset');
  api.addFile('documents/visualasset/methods');

  api.addFile('documents/sprite/sprite');
  api.addFile('documents/sprite/methods');
  api.addServerFile('documents/sprite/subscriptions');

  api.addFile('documents/mesh/mesh');

  // Tools

  api.addFile('tools/tools');
  api.addFile('tools/tool');

  // Components

  api.addFile('components/components');

  api.addUnstyledComponent('components/assetslist/assetslist');
  api.addUnstyledComponent('components/assetinfo/assetinfo');
  api.addUnstyledComponent('components/navigator/navigator');
  api.addUnstyledComponent('components/palette/palette');
  api.addUnstyledComponent('components/materials/materials');
  api.addUnstyledComponent('components/toolbox/toolbox');

  api.addUnstyledComponent('components/shadingsphere/shadingsphere');
  api.addFile('components/shadingsphere/normalpicker');

  api.addUnstyledComponent('components/pixelcanvas/pixelcanvas');
  api.addFile('components/pixelcanvas/mouse');
  api.addFile('components/pixelcanvas/grid');
  api.addFile('components/pixelcanvas/cursor');
  api.addFile('components/pixelcanvas/camera');

  // Engine

  api.addFile('engine/engine');
  api.addFile('engine/sprite');

  // Sprite editor

  api.addComponent('spriteeditor/spriteeditor');
  api.addFile('spriteeditor/tools/tools');
  api.addFile('spriteeditor/tools/pencil');
  api.addFile('spriteeditor/tools/eraser');
  api.addFile('spriteeditor/tools/colorpicker');
  api.addFile('spriteeditor/tools/colorfill');

});
