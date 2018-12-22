AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Debug extends FM.Action
  constructor: ->
    super arguments...

    @name = "Debug"
    @shortcut = AC.Keys.graveAccent

  active: -> @options.editor().debug()

  execute: ->
    debugField = @options.editor().debug
    debugField not debugField()
