AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Arrow extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Arrow'

  constructor: ->
    super arguments...

    @name = "Arrow"
    @shortcut = key: AC.Keys.escape
    @icon = '/landsofillusions/assets/editor/icons/arrow.png'
