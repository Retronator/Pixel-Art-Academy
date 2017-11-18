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

    xCoordinates = [[@mouseState.x, 1]]

    symmetryXOrigin = @options.editor().symmetryXOrigin()

    if symmetryXOrigin?
      mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push [mirroredX, -1]

    for [xCoordinate, xNormalFactor] in xCoordinates
      # Create the new pixel.
      pixel =
        x: xCoordinate
        y: @mouseState.y
        normal: @options.editor().shadingSphere().currentNormal().clone()

      pixel.normal.x *= xNormalFactor
  
      # See if we're setting a palette color.
      palette = @options.editor().palette()
      ramp = palette.currentRamp()
      shade = palette.currentShade()
  
      if ramp? and shade?
        pixel.paletteColor = {ramp, shade}
  
      # See if we're setting a named color.
      materialIndex = @options.editor().materials().currentIndex()
      pixel.materialIndex = materialIndex if materialIndex?
  
      # See if we're painting a normal.
      paintNormals = @options.editor().paintNormals?()
  
      spriteData = @options.editor().spriteData()
      existingPixel = _.find spriteData.layers?[0]?.pixels, (searchPixel) -> pixel.x is searchPixel.x and pixel.y is searchPixel.y
  
      if paintNormals and existingPixel
        # Get the color from the existing pixel.
        for property in ['materialIndex', 'paletteColor']
          pixel[property] = existingPixel[property] if existingPixel[property]?
  
      # Nothing to do if we don't have a color selected.
      continue unless pixel.paletteColor or pixel.materialIndex?
  
      # Do we even need to add this pixel? See if one just like it is already there.
      exactMatch = LOI.Assets.Sprite.documents.findOne
        _id: spriteData._id
        "layers.#{0}.pixels": pixel

      continue if exactMatch
      
      @_callMethod spriteData._id, 0, pixel

  # Override to call another method.
  _callMethod: (spriteId, layer, pixel) ->
    LOI.Assets.Sprite.addPixel spriteId, layer, pixel
