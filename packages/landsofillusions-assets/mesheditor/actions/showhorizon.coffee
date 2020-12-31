AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowHorizon extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowHorizon'
  @displayName: -> "Show horizon"
  @fileDataProperty: -> 'horizonEnabled'

  @initialize()
