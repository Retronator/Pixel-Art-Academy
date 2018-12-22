AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.ColorFill extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ColorFill'

  constructor: ->
    super arguments...

    @name = "Color fill"
    @shortcut = key: AC.Keys.g
    @icon = '/landsofillusions/assets/editor/icons/color-fill.png'

  _callMethod: (spriteId, layer, pixel) ->
    # Make sure we're filling inside of bounds.
    spriteData = @options.editor().spriteData()
    return unless spriteData.bounds.left <= pixel.x <= spriteData.bounds.right and spriteData.bounds.top <= pixel.y <= spriteData.bounds.bottom

    LOI.Assets.Sprite.colorFill spriteId, layer, pixel
