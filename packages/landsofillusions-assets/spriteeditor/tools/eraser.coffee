AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Eraser extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Eraser"
    @shortcut = AC.Keys.e

  onMouseDown: (event) ->
    super

    @applyEraser()

  onMouseMove: (event) ->
    super

    @applyEraser()

  applyEraser: ->
    return unless @mouseState.leftButton

    # Do we even need to remove this pixel? See if it is even there.
    spriteData = @options.editor().spriteData()

    pixel =
      x: @mouseState.x
      y: @mouseState.y

    existing = LOI.Assets.Sprite.documents.findOne
      _id: spriteData._id
      "layers.#{0}.pixels":
        $elemMatch: pixel

    return unless existing

    LOI.Assets.Sprite.removePixel spriteData._id, 0, pixel
