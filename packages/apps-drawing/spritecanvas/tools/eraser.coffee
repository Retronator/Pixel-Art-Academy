LOI = LandsOfIllusions
SpriteCanvas = PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas

class SpriteCanvas.Eraser extends SpriteCanvas.Tool
  @register 'SpriteCanvas.Eraser'
  
  mouseDown: (event) ->
    super

    @applyBrush()

  mouseMove: (event) ->
    super

    @applyBrush()

  applyBrush: ->
    return unless @mouseState.leftButton

    data = @spriteData()

    # Do we even need to remove this pixel? See if it is even there.
    existing = LOI.Assets.Sprite.documents.findOne
      _id: data._id
      pixels:
        $elemMatch:
          x: @mouseState.x
          y: @mouseState.y

    return unless existing

    Meteor.call 'spriteRemovePixel', data._id, @mouseState.x, @mouseState.y
