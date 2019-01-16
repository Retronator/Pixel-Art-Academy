AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ShowPixelGrid extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ShowPixelGrid'
  @displayName: -> "Show pixel grid"
  @fileDataProperty: -> 'pixelGridEnabled'
    
  @initialize()
