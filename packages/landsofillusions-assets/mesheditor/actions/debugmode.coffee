AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.DebugMode extends FM.Action
  # boolean if debug mode is active
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.DebugMode'
  @displayName: -> "Debug mode"
    
  @initialize()

  constructor: ->
    super arguments...

  active: -> @data.value()

  execute: ->
    @data.value not @data.value()
