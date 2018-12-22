AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.PixelImage extends FM.Action
  constructor: ->
    super arguments...

    @name = "Pixel image"

  active: -> @options.editor().pixelImageVisible()

  execute: ->
    pixelImageVisibleField = @options.editor().pixelImageVisible
    pixelImageVisibleField not pixelImageVisibleField()
