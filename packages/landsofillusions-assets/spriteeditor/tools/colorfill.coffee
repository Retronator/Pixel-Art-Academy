AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorFill extends LOI.Assets.SpriteEditor.Tools.Pencil
  constructor: ->
    super

    @name = "Color fill"
    @shortcut = AC.Keys.g

  _callMethod: (spriteId, layer, pixel) ->
    LOI.Assets.Sprite.colorFill spriteId, layer, pixel
