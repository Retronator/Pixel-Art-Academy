AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.SourceImage extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Source image"

  toolClass: ->
    'enabled' if @options.editor().sourceImageVisible()

  method: ->
    sourceImageVisibleField = @options.editor().sourceImageVisible
    sourceImageVisibleField not sourceImageVisibleField()
