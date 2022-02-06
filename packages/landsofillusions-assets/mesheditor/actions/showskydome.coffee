AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.ShowSkydome extends LOI.Assets.Editor.Actions.ShowAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.ShowSkydome'
  @displayName: -> "Show skydome"
  @fileDataProperty: -> 'skydomeVisible'
    
  @initialize()
