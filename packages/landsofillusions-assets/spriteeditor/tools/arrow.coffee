AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Arrow extends LOI.Assets.SpriteEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Arrow'
  @displayName: -> "Arrow"
    
  @initialize()

  constructor: ->
    super arguments...

    @shortcut = key: AC.Keys.escape
