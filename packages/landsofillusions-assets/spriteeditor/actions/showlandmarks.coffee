AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ShowLandmarks extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ShowLandmarks'
  @displayName: -> "Show landmarks"
  @fileDataProperty: -> 'landmarksEnabled'

  @initialize()
