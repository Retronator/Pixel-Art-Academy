Package.describe({
  name: 'apps-drawing',
  version: '0.0.1'
});

Package.onUse(function(api) {
  api.use('pixelartacademy');
  api.use('pixelboy');

  api.export('PixelArtAcademy');

  api.addFiles('drawing.coffee');
  api.addFiles('drawing.html');
  api.addFiles('drawing.styl');

  api.addFiles('spritecanvas/spritecanvas.coffee');
  api.addFiles('spritecanvas/spritecanvas.html');
  api.addFiles('spritecanvas/spritecanvas.styl');
  api.addFiles('spritecanvas/camera.coffee');
  api.addFiles('spritecanvas/grid.coffee');
  api.addFiles('spritecanvas/mouse.coffee');
  api.addFiles('spritecanvas/cursor.coffee');

  api.addFiles('spritecanvas/sprite/sprite.coffee');
  api.addFiles('spritecanvas/sprite/methods.coffee');

  api.addFiles('spritecanvas/tools/tools.html');
  api.addFiles('spritecanvas/tools/tools.styl');
  api.addFiles('spritecanvas/tools/tool.coffee');
  api.addFiles('spritecanvas/tools/pencil.coffee');
  api.addFiles('spritecanvas/tools/eraser.coffee');
  api.addFiles('spritecanvas/tools/colorpicker.coffee');
  api.addFiles('spritecanvas/tools/colorfill.coffee');

  api.addFiles('sprite/sprite.coffee');
  api.addFiles('sprite/sprite.html');
  api.addFiles('sprite/sprite.styl');

  api.addFiles('sprites/sprites.coffee');
  api.addFiles('sprites/sprites.html');
  api.addFiles('sprites/sprites.styl');
  api.addFiles('sprites/methods.coffee');
  api.addFiles('sprites/subscriptions.coffee', 'server');

  api.addFiles('components/components.coffee');

  api.addFiles('components/colormap/colormap.coffee');
  api.addFiles('components/colormap/colormap.html');
  api.addFiles('components/colormap/colormap.styl');
  api.addFiles('components/colormap/methods.coffee');

  api.addFiles('components/navigator/navigator.coffee');
  api.addFiles('components/navigator/navigator.html');
  api.addFiles('components/navigator/navigator.styl');

  api.addFiles('components/palette/palette.coffee');
  api.addFiles('components/palette/palette.html');
  api.addFiles('components/palette/palette.styl');
  api.addFiles('components/palette/methods.coffee');
  api.addFiles('components/palette/subscriptions.coffee', 'server');
});
