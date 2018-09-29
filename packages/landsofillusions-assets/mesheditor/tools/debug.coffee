AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.Debug extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Debug"
    @shortcut = AC.Keys.graveAccent

  toolClass: ->
    'enabled' if @options.editor().debug()

  method: ->
    debugField = @options.editor().debug
    debugField not debugField()
