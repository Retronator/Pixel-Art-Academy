AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowEdges extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowEdges'
  @displayName: -> "Show edges"
  @fileDataProperty: -> 'edgesEnabled'
    
  @initialize()
