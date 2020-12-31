AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.PaintNormals extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.PaintNormals'
  @displayName: -> "Paint normals"
    
  @initialize()

  constructor: ->
    super arguments...

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

  active: -> @paintNormalsData.value()

  execute: ->
    @paintNormalsData.value not @paintNormalsData.value()
