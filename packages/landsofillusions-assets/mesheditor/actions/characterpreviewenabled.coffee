AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.CharacterPreviewEnabled extends LOI.Assets.Editor.Actions.ShowHelperAction
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.CharacterPreviewEnabled'
  @displayName: -> "Character preview"
  @helperClass: -> LOI.Assets.MeshEditor.Helpers.CharacterPreview
    
  @initialize()
