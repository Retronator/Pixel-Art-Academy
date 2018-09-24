AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PlaneGrid extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Plane grid"
    @shortcut = AC.Keys.semicolon
    @shortcutCommandOrCtrl = true

  toolClass: ->
    'enabled' if @options.editor().planeGridEnabled()

  method: ->
    planeGridEnabledField = @options.editor().planeGridEnabled
    planeGridEnabledField not planeGridEnabledField()
