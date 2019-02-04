AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShadowsEnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShadowsEnabled'
  @displayName: -> "Draw shadows"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.ShadowsEnabled
    
  @initialize()
