AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Pencil extends LOI.Assets.SpriteEditor.Tools.Tool
  # paintNormals: boolean whether only normals are being painted
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Pencil'
  @displayName: -> "Pencil"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @applyPencil()

  onMouseMove: (event) ->
    super arguments...

    @applyPencil()

  applyPencil: ->
    return unless @mouseState.leftButton

    xCoordinates = [[@mouseState.x, 1]]

    editor = @interface.getEditorForActiveFile()
    spriteData = editor.spriteData()

    # TODO: Get symmetry from interface data.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()

    if symmetryXOrigin?
      mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push [mirroredX, -1]

    for [xCoordinate, xNormalFactor] in xCoordinates
      # Create the new pixel.
      pixel =
        x: xCoordinate
        y: @mouseState.y
        
      # If we have fixed bounds, make sure we're inside.
      if spriteData.bounds?.fixed
        continue unless spriteData.bounds.left <= pixel.x <= spriteData.bounds.right and spriteData.bounds.top <= pixel.y <= spriteData.bounds.bottom

      # TODO: Get normal from interface data.
      normal = null # @options.editor().shadingSphere?().currentNormal().clone()

      if normal
        pixel.normal = normal
        pixel.normal.x *= xNormalFactor
  
      # See if we're setting a palette color.
      @paletteData = @interface.getComponentData LOI.Assets.Components.Palette
      ramp = @paletteData.get 'ramp'
      shade = @paletteData.get 'shade'
  
      if ramp? and shade?
        pixel.paletteColor = {ramp, shade}
  
      # See if we're setting a named color.
      @meterialsData = @interface.getComponentData LOI.Assets.Components.Materials
      materialIndex = @meterialsData.get 'index'
      pixel.materialIndex = materialIndex if materialIndex?
  
      # See if we're painting a normal.
      paintNormals = @data.get 'paintNormals'
  
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
