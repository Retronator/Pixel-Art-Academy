AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.DebugMode extends FM.Action
  # boolean if debug mode is active
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.DebugMode'
  @displayName: -> "Show debug"
    
  @initialize()

  constructor: ->
    super arguments...

  active: -> @data.value()

  execute: ->
    @data.value not @data.value()
