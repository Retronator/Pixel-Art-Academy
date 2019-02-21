AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ShowSafeArea extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ShowSafeArea'
  @displayName: -> "Show safe area"
  @fileDataProperty: -> 'safeAreaEnabled'
    
  @initialize()
