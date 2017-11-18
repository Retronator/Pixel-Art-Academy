AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.PaintNormals extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Paint normals"
    @shortcut = AC.Keys.n

  toolClass: ->
    'enabled' if @options.editor().paintNormals()

  method: ->
    paintNormalsField = @options.editor().paintNormals
    paintNormalsField not paintNormalsField()
