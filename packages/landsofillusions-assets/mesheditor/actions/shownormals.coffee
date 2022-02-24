AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowNormals extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowNormals'
  @displayName: -> "Show normals"
  @fileDataProperty: -> 'normalsOnly'
  
  @initialize()
