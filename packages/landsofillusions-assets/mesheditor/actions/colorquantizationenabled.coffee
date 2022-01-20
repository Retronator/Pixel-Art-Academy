AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ColorQuantizationEnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ColorQuantizationEnabled'
  @displayName: -> "Color quantization"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.ColorQuantizationEnabled
    
  @initialize()
