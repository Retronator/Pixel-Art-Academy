AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ShowShading extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ShowShading'
  @displayName: -> "Show shading"
  @fileDataProperty: -> 'shadingEnabled'

  @initialize()
