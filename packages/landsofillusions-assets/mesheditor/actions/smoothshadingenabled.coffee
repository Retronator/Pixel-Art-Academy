AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.SmoothShadingEnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.SmoothShadingEnabled'
  @displayName: -> "Smooth shading"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.SmoothShadingEnabled
    
  @initialize()
