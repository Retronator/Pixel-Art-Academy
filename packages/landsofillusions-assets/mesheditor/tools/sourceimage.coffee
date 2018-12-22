AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.SourceImage extends FM.Action
  constructor: ->
    super arguments...

    @name = "Source image"

  active: -> @options.editor().sourceImageVisible()

  method: ->
    sourceImageVisibleField = @options.editor().sourceImageVisible
    sourceImageVisibleField not sourceImageVisibleField()
