AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.CharacterPreviewSelection extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.CharacterPreviewSelection'
  @displayName: -> "Choose character …"

  @initialize()

  execute: ->
    @interface.displayDialog
      contentComponentId: LOI.Assets.MeshEditor.CharacterSelectionDialog.id()
