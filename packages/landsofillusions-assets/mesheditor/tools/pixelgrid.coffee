AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PixelGrid extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Pixel grid"
    @shortcut = AC.Keys.singleQuote
    @shortcutCommandOrCtrl = true

  toolClass: ->
    'enabled' if @options.editor().pixelGridEnabled()

  method: ->
    pixelGridEnabledField = @options.editor().pixelGridEnabled
    pixelGridEnabledField not pixelGridEnabledField()
