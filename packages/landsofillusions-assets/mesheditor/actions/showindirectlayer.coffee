AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowIndirectLayer extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowIndirectLayer'
  @displayName: -> "Show indirect layer"
  @fileDataProperty: -> 'indirectLayerOnly'
    
  @initialize()
