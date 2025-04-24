AC = Artificial.Control
AS = Artificial.Spectrum
FM = FataMorgana
LOI = LandsOfIllusions

class BrushSize extends FM.Action
  enabled: -> true

  constructor: ->
    super arguments...

    @brushHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Brush
    @sign = 1

  execute: ->
    # Only change brush size if the active tool is an aliased stroke or a line.
    return unless @interface.activeTool() instanceof LOI.Assets.SpriteEditor.Tools.AliasedStroke or @interface.activeTool().id() is LOI.Assets.SpriteEditor.Tools.Line.id()

    keyboardState = AC.Keyboard.getState()

    if @brushHelper.round() and keyboardState.isKeyDown AC.Keys[0]
      currentAliasedShape = @brushHelper.aliasedShape()
      diameter = @brushHelper.diameter()

      # Gradually change size until the shape is different.
      while diameter >= 1
        diameter += @sign / 100
        newAliasedShape = @brushHelper.aliasedShapeForDiameter diameter

        # Reject shapes with only one pixel in first line (except for 3x3).
        continue if newAliasedShape[0].length > 3 and _.sum(newAliasedShape[0]) is 1

        break unless _.isEqual currentAliasedShape, newAliasedShape

      @brushHelper.setDiameter Math.max 1, diameter

    else
      # We prefer diameter slightly smaller than the integer to pick less filled shape variants.
      currentSize = Math.ceil @brushHelper.diameter()
      newSize = Math.max 1, currentSize + @sign
      perfectNewSize = AS.PixelArt.Circle.perfectDiameters[newSize - 1]
      @brushHelper.setDiameter perfectNewSize or newSize

class LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease extends BrushSize
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.BrushSizeIncrease'
  @displayName: -> "Increase brush size"

  @initialize()

class LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease extends BrushSize
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.BrushSizeDecrease'
  @displayName: -> "Decrease brush size"

  @initialize()

  constructor: ->
    super arguments...

    @sign = -1
