AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Eraser extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Eraser'
  @displayName: -> "Eraser"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @applyEraser()

  onMouseMove: (event) ->
    super arguments...

    @applyEraser()

  applyEraser: ->
    return unless @mouseState.leftButton

    spriteData = @editor().spriteData()    
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
    layerIndex = paintHelper.layerIndex()
    layer = spriteData.layers?[layerIndex]

    xCoordinates = [@mouseState.x]

    # TODO: Get symmetry from interface data.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()

    if symmetryXOrigin?
      mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push mirroredX

    layerOrigin =
      x: layer?.origin?.x or 0
      y: layer?.origin?.y or 0

    for xCoordinate in xCoordinates
      pixel =
        x: xCoordinate - layerOrigin.x
        y: @mouseState.y - layerOrigin.y

      # Do we even need to remove this pixel? See if it is even there.
      existing = LOI.Assets.Sprite.documents.findOne
        _id: spriteData._id
        "layers.#{layerIndex}.pixels":
          $elemMatch: pixel

      continue unless existing

      LOI.Assets.Sprite.removePixel spriteData._id, layerIndex, pixel
