AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.PaintNormals extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.PaintNormals'

  constructor: (@options) ->
    super arguments...

    @caption = "Paint normals"
    @shortcut = key: AC.Keys.n

  active: -> @options.editor().paintNormals()

  execute: ->
    paintNormalsField = @options.editor().paintNormals
    paintNormalsField not paintNormalsField()
