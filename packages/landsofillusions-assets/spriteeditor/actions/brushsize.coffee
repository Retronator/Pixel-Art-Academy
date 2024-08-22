AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class BrushSize extends FM.Action
  @roundBrushSizes = [
    1
    2
    2.82
    4
    5
    5.84
    6.33
    7.62
    8.95
    9.48
    10.77
    12
    12.64
    13.92
    15
    15.55
    16.97
    18
    19
    19.84
    20.59
    21.95
    23
    23.53
    24.74
    25.97
    26.69
    27.9
    28.85
    29.69
    30.6
  ]

  enabled: -> true

  constructor: ->
    super arguments...

    @brushHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Brush
    @sign = 1

  execute: ->
    # Only change brush size if the active tool is an aliased stroke.
    return unless @interface.activeTool() instanceof LOI.Assets.SpriteEditor.Tools.AliasedStroke

    keyboardState = AC.Keyboard.getState()

    if @brushHelper.round() and keyboardState.isCommandOrControlDown()
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
      perfectNewSize = @constructor.roundBrushSizes[newSize - 1]
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
