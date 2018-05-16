LOI = LandsOfIllusions
SpriteCanvas = PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas

class SpriteCanvas.ColorFill extends SpriteCanvas.Tool
  @register 'SpriteCanvas.ColorFill'

  mouseDown: (event) ->
    super

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

    Meteor.call 'spriteColorFill', data._id, @mouseState.x, @mouseState.y, colorIndex, relativeShade

  colorFillStyle: ->
    # Get the color from the palette.
    colorData = @spriteCanvas.drawing.palette().currentColor()
    return unless colorData

    color = THREE.Color.fromObject colorData

    backgroundColor: "##{color.getHexString()}"
