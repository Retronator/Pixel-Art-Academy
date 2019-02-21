AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowPlaneGrid extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowPlaneGrid'
  @displayName: -> "Show plane grid"
  @fileDataProperty: -> 'planeGridEnabled'
    
  @initialize()
