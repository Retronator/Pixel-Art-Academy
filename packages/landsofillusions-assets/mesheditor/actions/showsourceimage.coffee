AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowSourceImage extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowSourceImage'
  @displayName: -> "Show source image"
  @fileDataProperty: -> 'sourceImageEnabled'
    
  @initialize()
