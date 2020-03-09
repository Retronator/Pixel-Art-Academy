AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.PBREnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.PBREnabled'
  @displayName: -> "Physically based rendering"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.PBREnabled
    
  @initialize()
