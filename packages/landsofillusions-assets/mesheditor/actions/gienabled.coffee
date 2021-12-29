AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.GIEnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.GIEnabled'
  @displayName: -> "Global illumination"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.GIEnabled
    
  @initialize()
