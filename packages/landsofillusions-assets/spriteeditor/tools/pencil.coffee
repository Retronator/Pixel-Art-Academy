AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Pencil extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Pencil"
    @shortcut = AC.Keys.b

  onMouseDown: (event) ->
    super

    @applyPencil()

  onMouseMove: (event) ->
    super

    @applyPencil()

  applyPencil: ->
    return unless @mouseState.leftButton

    # Create the new pixel.
    pixel =
      x: @mouseState.x
      y: @mouseState.y
      normal: @options.editor().shadingSphere().currentNormal()

    # See if we're setting a palette color.
    palette = @options.editor().palette()
    ramp = palette.currentRamp()
    shade = palette.currentShade()

    if ramp? and shade?
      pixel.paletteColor = {ramp, shade}

    # See if we're setting a named color.
    materialIndex = @options.editor().materials().currentIndex()
    pixel.materialIndex = materialIndex if materialIndex?

    # Nothing to do if we don't have a color selected.
    return unless pixel.paletteColor or pixel.materialIndex?

    # Do we even need to add this pixel? See if it's already there.
    spriteData = @options.editor().spriteData()

    existing = LOI.Assets.Sprite.documents.findOne
      _id: spriteData._id
      "layers.#{0}.pixels": pixel

    return if existing
    
    @_callMethod spriteData._id, 0, pixel

  # Override to call another method.
  _callMethod: (spriteId, layer, pixel) ->
    LOI.Assets.Sprite.addPixel spriteId, layer, pixel
