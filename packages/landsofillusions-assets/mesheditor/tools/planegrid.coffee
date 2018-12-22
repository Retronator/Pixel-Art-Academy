AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PlaneGrid extends FM.Action
  constructor: ->
    super arguments...

    @name = "Plane grid"
    @shortcut = AC.Keys.semicolon
    @shortcutCommandOrCtrl = true

  active: -> @options.editor().planeGridEnabled()

  execute: ->
    planeGridEnabledField = @options.editor().planeGridEnabled
    planeGridEnabledField not planeGridEnabledField()
