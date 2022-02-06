AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.LightShadowsEnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.LightShadowsEnabled'
  @displayName: -> "Enable geometric light shadows"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.LightShadowsEnabled
    
  @initialize()
