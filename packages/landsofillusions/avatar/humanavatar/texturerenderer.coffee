AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar.TextureRenderer
  @textureSides: [
    LOI.Engine.RenderingSides.Keys.Front
    LOI.Engine.RenderingSides.Keys.FrontLeft
    LOI.Engine.RenderingSides.Keys.Left
    LOI.Engine.RenderingSides.Keys.BackLeft
    LOI.Engine.RenderingSides.Keys.Back
    LOI.Engine.RenderingSides.Keys.BackRight
    LOI.Engine.RenderingSides.Keys.Right
    LOI.Engine.RenderingSides.Keys.FrontRight
  ]

  @sideWidth: 64
  @textureWidth: @sideWidth * @textureSides.length
  @textureHeight: 256
  @textureMagnification: 4

  constructor: (@options = {}) ->
    # Create and automatically update textures.
    @paletteDataCanvas = new AM.Canvas @constructor.textureWidth, @constructor.textureHeight
    @paletteDataContext = @paletteDataCanvas.context

    @normalsCanvas = new AM.Canvas @constructor.textureWidth, @constructor.textureHeight
    @normalsContext = @normalsCanvas.context

  render: ->
    return unless @options.humanAvatar.dataReady()
    return unless @options.humanAvatarRenderer.ready()

    # Render palette color map.
    @paletteDataContext.setTransform 1, 0, 0, 1, 0, 0
    @paletteDataContext.clearRect 0, 0, @paletteDataCanvas.width, @paletteDataCanvas.height

    @paletteDataContext.save()

    drawOptions = (side, sideIndex) =>
      rootPart: @options.humanAvatarRenderer.options.part
      textureOffset: @constructor.sideWidth * sideIndex
      side: side

    for side, sideIndex in @constructor.textureSides
      @options.humanAvatarRenderer.drawToContext @paletteDataContext, _.extend drawOptions(side, sideIndex),
        renderPaletteData: true

      @paletteDataContext.restore()

    @scaledPaletteDataCanvas = AS.Hqx.scale @paletteDataCanvas, @constructor.textureMagnification, AS.Hqx.Modes.NoBlending, false

    # Render normal map.
    @normalsContext.setTransform 1, 0, 0, 1, 0, 0
    @normalsContext.clearRect 0, 0, @normalsCanvas.width, @normalsCanvas.height

    @normalsContext.save()

    for side, sideIndex in @constructor.textureSides
      @options.humanAvatarRenderer.drawToContext @normalsContext, _.extend drawOptions(side, sideIndex),
        renderNormalData: true

      @normalsContext.restore()

    normalImageData = @normalsContext.getImageData 0, 0, @normalsCanvas.width, @normalsCanvas.height
    AS.ImageDataHelpers.expandPixels normalImageData, 1
    @normalsContext.putImageData normalImageData, 0, 0

    @scaledNormalsCanvas = AS.Hqx.scale @normalsCanvas, @constructor.textureMagnification, AS.Hqx.Modes.Default, true

    # Notify that rendering has completed.
    true
