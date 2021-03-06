AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.Components.Tools.ColorFill extends LOI.Assets.Components.Tools.Pencil
  constructor: ->
    super arguments...

    @name = "Color fill"
    @shortcut = AC.Keys.g

  _callMethod: (spriteId, layer, pixel) ->
    # Make sure we're filling inside of bounds.
    spriteData = @options.editor().spriteData()
    return unless spriteData.bounds.left <= pixel.x <= spriteData.bounds.right and spriteData.bounds.top <= pixel.y <= spriteData.bounds.bottom

    LOI.Assets.Sprite.colorFill spriteId, layer, pixel
