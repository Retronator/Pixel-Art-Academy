AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowEdgePixels extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowEdgePixels'
  @displayName: -> "Show edge pixels"
  @fileDataProperty: -> 'edgePixelsEnabled'
    
  @initialize()
