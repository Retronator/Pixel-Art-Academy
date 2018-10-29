AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Eraser extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Eraser"
    @shortcut = AC.Keys.e

  onMouseDown: (event) ->
    super arguments...

    @applyEraser()

  onMouseMove: (event) ->
    super arguments...

    @applyEraser()

  applyEraser: ->
    return unless @mouseState.leftButton

    # Do we even need to remove this pixel? See if it is even there.
    spriteData = @options.editor().spriteData()

    xCoordinates = [@mouseState.x]

    symmetryXOrigin = @options.editor().symmetryXOrigin?()

    if symmetryXOrigin?
      mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      xCoordinates.push mirroredX

    for xCoordinate in xCoordinates
      pixel =
        x: xCoordinate
        y: @mouseState.y

      existing = LOI.Assets.Sprite.documents.findOne
        _id: spriteData._id
        "layers.#{0}.pixels":
          $elemMatch: pixel

      return unless existing

      LOI.Assets.Sprite.removePixel spriteData._id, 0, pixel
