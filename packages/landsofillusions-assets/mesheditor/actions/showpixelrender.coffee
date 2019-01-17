AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowPixelRender extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowPixelRender'
  @displayName: -> "Show pixel render"
  @fileDataProperty: -> 'pixelRenderEnabled'

  @initialize()
