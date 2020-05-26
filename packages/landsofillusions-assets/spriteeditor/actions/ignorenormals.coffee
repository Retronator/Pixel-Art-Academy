AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.IgnoreNormals extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.IgnoreNormals'
  @displayName: -> "Ignore normals"
    
  @initialize()

  constructor: ->
    super arguments...

    @ignoreNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'ignoreNormals'

  active: -> @ignoreNormalsData.value()

  execute: ->
    @ignoreNormalsData.value not @ignoreNormalsData.value()
