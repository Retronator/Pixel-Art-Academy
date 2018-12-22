AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PixelGrid extends FM.Action
  constructor: ->
    super arguments...

    @name = "Pixel grid"
    @shortcut = AC.Keys.singleQuote
    @shortcutCommandOrCtrl = true

  active: -> @options.editor().pixelGridEnabled()

  execute: ->
    pixelGridEnabledField = @options.editor().pixelGridEnabled
    pixelGridEnabledField not pixelGridEnabledField()
