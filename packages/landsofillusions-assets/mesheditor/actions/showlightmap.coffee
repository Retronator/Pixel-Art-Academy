AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowLightmap extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowLightmap'
  @displayName: -> "Show lightmap"
  @fileDataProperty: -> 'lightmapOnly'
  
  @initialize()
