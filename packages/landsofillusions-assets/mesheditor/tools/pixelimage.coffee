AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PixelImage extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Pixel image"

  toolClass: ->
    'enabled' if @options.editor().pixelImageVisible()

  method: ->
    pixelImageVisibleField = @options.editor().pixelImageVisible
    pixelImageVisibleField not pixelImageVisibleField()
