AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Renderer extends LOI.Character.Avatar.Renderers.Renderer
  getPreviewImage: (options = {}) ->
    _.defaults options,
      width: 50
      height: 50

    # Draw renderer to canvas.
    canvas = new AM.Canvas options.width, options.height
    canvas.context.setTransform 1, 0, 0, 1, Math.floor(canvas.width / 2), Math.floor(canvas.height / 2)

    @drawToContext canvas.context,
      rootPart: options.rootPart
      lightDirection: new THREE.Vector3(0, -1, -1).normalize()
      side: LOI.Engine.RenderingSides.Keys.Front

    canvas
