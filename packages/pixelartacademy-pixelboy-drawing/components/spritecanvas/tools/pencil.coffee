LOI = LandsOfIllusions
SpriteCanvas = PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas

class SpriteCanvas.Pencil extends SpriteCanvas.Tool
  @register 'SpriteCanvas.Pencil'

  mouseDown: (event) ->
    super

    @applyBrush()

  mouseMove: (event) ->
    super

    @applyBrush()

  applyBrush: ->
    return unless @mouseState.leftButton

    palette = @spriteCanvas.drawing.palette()
    ramp = palette.currentRamp()
    shade = palette.currentShade()
    colorIndex = @getIndexWithRamp ramp

    unless colorIndex?
      # We still don't have an index, so we should add a new one.
      colorIndex = @addNewIndex null, ramp, shade

    data = @spriteData()

    # Figure out the relative shade compared to it.
    relativeShade = shade - (data.colorMap[colorIndex]?.shade or 0)

    # Do we even need to add this pixel? See if it's already there.
    existing = LOI.Assets.Sprite.documents.findOne
      _id: data._id
      pixels:
        x: @mouseState.x
        y: @mouseState.y
        colorIndex: colorIndex
        relativeShade: relativeShade

    return if existing

    Meteor.call 'spriteAddPixel', data._id, @mouseState.x, @mouseState.y, colorIndex, relativeShade
