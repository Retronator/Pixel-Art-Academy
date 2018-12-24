AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.PaintNormals extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.PaintNormals'
  @displayName: -> "Paint normals"
    
  @initialize()

  active: -> @interface.parent.paintNormals()

  execute: ->
    paintNormalsField = @interface.parent.paintNormals
    paintNormalsField not paintNormalsField()
